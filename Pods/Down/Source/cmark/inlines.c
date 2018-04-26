#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "cmark_ctype.h"
#include "config.h"
#include "node.h"
#include "parser.h"
#include "references.h"
#include "cmark.h"
#include "houdini.h"
#include "utf8.h"
#include "scanners.h"
#include "inlines.h"

static const char *EMDASH = "\xE2\x80\x94";
static const char *ENDASH = "\xE2\x80\x93";
static const char *ELLIPSES = "\xE2\x80\xA6";
static const char *LEFTDOUBLEQUOTE = "\xE2\x80\x9C";
static const char *RIGHTDOUBLEQUOTE = "\xE2\x80\x9D";
static const char *LEFTSINGLEQUOTE = "\xE2\x80\x98";
static const char *RIGHTSINGLEQUOTE = "\xE2\x80\x99";

// Macros for creating various kinds of simple.
#define make_str(s) make_literal(CMARK_NODE_TEXT, s)
#define make_code(s) make_literal(CMARK_NODE_CODE, s)
#define make_raw_html(s) make_literal(CMARK_NODE_HTML_INLINE, s)
#define make_linebreak() make_simple(CMARK_NODE_LINEBREAK)
#define make_softbreak() make_simple(CMARK_NODE_SOFTBREAK)
#define make_emph() make_simple(CMARK_NODE_EMPH)
#define make_strong() make_simple(CMARK_NODE_STRONG)

typedef struct delimiter {
  struct delimiter *previous;
  struct delimiter *next;
  cmark_node *inl_text;
  bufsize_t position;
  unsigned char delim_char;
  bool can_open;
  bool can_close;
  bool active;
} delimiter;

typedef struct {
  cmark_chunk input;
  bufsize_t pos;
  cmark_reference_map *refmap;
  delimiter *last_delim;
} subject;

static CMARK_INLINE bool S_is_line_end_char(char c) {
  return (c == '\n' || c == '\r');
}

static delimiter *S_insert_emph(subject *subj, delimiter *opener,
                                delimiter *closer);

static int parse_inline(subject *subj, cmark_node *parent, int options);

static void subject_from_buf(subject *e, cmark_strbuf *buffer,
                             cmark_reference_map *refmap);
static bufsize_t subject_find_special_char(subject *subj, int options);

// Create an inline with a literal string value.
static CMARK_INLINE cmark_node *make_literal(cmark_node_type t, cmark_chunk s) {
  cmark_node *e = (cmark_node *)calloc(1, sizeof(*e));
  if (e != NULL) {
    e->type = t;
    e->as.literal = s;
    e->next = NULL;
    e->prev = NULL;
    e->parent = NULL;
    e->first_child = NULL;
    e->last_child = NULL;
    // These fields aren't used for inlines:
    e->start_line = 0;
    e->start_column = 0;
    e->end_line = 0;
  }
  return e;
}

// Create an inline with no value.
static CMARK_INLINE cmark_node *make_simple(cmark_node_type t) {
  cmark_node *e = (cmark_node *)calloc(1, sizeof(*e));
  if (e != NULL) {
    e->type = t;
    e->next = NULL;
    e->prev = NULL;
    e->parent = NULL;
    e->first_child = NULL;
    e->last_child = NULL;
    // These fields aren't used for inlines:
    e->start_line = 0;
    e->start_column = 0;
    e->end_line = 0;
  }
  return e;
}

// Like make_str, but parses entities.
static cmark_node *make_str_with_entities(cmark_chunk *content) {
  cmark_strbuf unescaped = GH_BUF_INIT;

  if (houdini_unescape_html(&unescaped, content->data, content->len)) {
    return make_str(cmark_chunk_buf_detach(&unescaped));
  } else {
    return make_str(*content);
  }
}

// Duplicate a chunk by creating a copy of the buffer not by reusing the
// buffer like cmark_chunk_dup does.
static cmark_chunk chunk_clone(cmark_chunk *src) {
  cmark_chunk c;
  bufsize_t len = src->len;

  c.len = len;
  c.data = (unsigned char *)malloc(len + 1);
  c.alloc = 1;
  memcpy(c.data, src->data, len);
  c.data[len] = '\0';

  return c;
}

static cmark_chunk cmark_clean_autolink(cmark_chunk *url, int is_email) {
  cmark_strbuf buf = GH_BUF_INIT;

  cmark_chunk_trim(url);

  if (url->len == 0) {
    cmark_chunk result = CMARK_CHUNK_EMPTY;
    return result;
  }

  if (is_email)
    cmark_strbuf_puts(&buf, "mailto:");

  houdini_unescape_html_f(&buf, url->data, url->len);
  return cmark_chunk_buf_detach(&buf);
}

static CMARK_INLINE cmark_node *make_autolink(cmark_chunk url, int is_email) {
  cmark_node *link = make_simple(CMARK_NODE_LINK);
  link->as.link.url = cmark_clean_autolink(&url, is_email);
  link->as.link.title = cmark_chunk_literal("");
  cmark_node_append_child(link, make_str_with_entities(&url));
  return link;
}

static void subject_from_buf(subject *e, cmark_strbuf *buffer,
                             cmark_reference_map *refmap) {
  e->input.data = buffer->ptr;
  e->input.len = buffer->size;
  e->input.alloc = 0;
  e->pos = 0;
  e->refmap = refmap;
  e->last_delim = NULL;
}

static CMARK_INLINE int isbacktick(int c) { return (c == '`'); }

static CMARK_INLINE unsigned char peek_char(subject *subj) {
  // NULL bytes should have been stripped out by now.  If they're
  // present, it's a programming error:
  assert(!(subj->pos < subj->input.len && subj->input.data[subj->pos] == 0));
  return (subj->pos < subj->input.len) ? subj->input.data[subj->pos] : 0;
}

static CMARK_INLINE unsigned char peek_at(subject *subj, bufsize_t pos) {
  return subj->input.data[pos];
}

// Return true if there are more characters in the subject.
static CMARK_INLINE int is_eof(subject *subj) {
  return (subj->pos >= subj->input.len);
}

// Advance the subject.  Doesn't check for eof.
#define advance(subj) (subj)->pos += 1

static CMARK_INLINE bool skip_spaces(subject *subj) {
  bool skipped = false;
  while (peek_char(subj) == ' ' || peek_char(subj) == '\t') {
    advance(subj);
    skipped = true;
  }
  return skipped;
}

static CMARK_INLINE bool skip_line_end(subject *subj) {
  bool seen_line_end_char = false;
  if (peek_char(subj) == '\r') {
    advance(subj);
    seen_line_end_char = true;
  }
  if (peek_char(subj) == '\n') {
    advance(subj);
    seen_line_end_char = true;
  }
  return seen_line_end_char || is_eof(subj);
}

// Take characters while a predicate holds, and return a string.
static CMARK_INLINE cmark_chunk take_while(subject *subj, int (*f)(int)) {
  unsigned char c;
  bufsize_t startpos = subj->pos;
  bufsize_t len = 0;

  while ((c = peek_char(subj)) && (*f)(c)) {
    advance(subj);
    len++;
  }

  return cmark_chunk_dup(&subj->input, startpos, len);
}

// Try to process a backtick code span that began with a
// span of ticks of length openticklength length (already
// parsed).  Return 0 if you don't find matching closing
// backticks, otherwise return the position in the subject
// after the closing backticks.
static bufsize_t scan_to_closing_backticks(subject *subj,
                                           bufsize_t openticklength) {
  // read non backticks
  unsigned char c;
  while ((c = peek_char(subj)) && c != '`') {
    advance(subj);
  }
  if (is_eof(subj)) {
    return 0; // did not find closing ticks, return 0
  }
  bufsize_t numticks = 0;
  while (peek_char(subj) == '`') {
    advance(subj);
    numticks++;
  }
  if (numticks != openticklength) {
    return (scan_to_closing_backticks(subj, openticklength));
  }
  return (subj->pos);
}

// Parse backtick code section or raw backticks, return an inline.
// Assumes that the subject has a backtick at the current position.
static cmark_node *handle_backticks(subject *subj) {
  cmark_chunk openticks = take_while(subj, isbacktick);
  bufsize_t startpos = subj->pos;
  bufsize_t endpos = scan_to_closing_backticks(subj, openticks.len);

  if (endpos == 0) {      // not found
    subj->pos = startpos; // rewind
    return make_str(openticks);
  } else {
    cmark_strbuf buf = GH_BUF_INIT;

    cmark_strbuf_set(&buf, subj->input.data + startpos,
                     endpos - startpos - openticks.len);
    cmark_strbuf_trim(&buf);
    cmark_strbuf_normalize_whitespace(&buf);

    return make_code(cmark_chunk_buf_detach(&buf));
  }
}

// Scan ***, **, or * and return number scanned, or 0.
// Advances position.
static int scan_delims(subject *subj, unsigned char c, bool *can_open,
                       bool *can_close) {
  int numdelims = 0;
  bufsize_t before_char_pos;
  int32_t after_char = 0;
  int32_t before_char = 0;
  int len;
  bool left_flanking, right_flanking;

  if (subj->pos == 0) {
    before_char = 10;
  } else {
    before_char_pos = subj->pos - 1;
    // walk back to the beginning of the UTF_8 sequence:
    while (peek_at(subj, before_char_pos) >> 6 == 2 && before_char_pos > 0) {
      before_char_pos -= 1;
    }
    len = cmark_utf8proc_iterate(subj->input.data + before_char_pos,
                                 subj->pos - before_char_pos, &before_char);
    if (len == -1) {
      before_char = 10;
    }
  }

  if (c == '\'' || c == '"') {
    numdelims++;
    advance(subj); // limit to 1 delim for quotes
  } else {
    while (peek_char(subj) == c) {
      numdelims++;
      advance(subj);
    }
  }

  len = cmark_utf8proc_iterate(subj->input.data + subj->pos,
                               subj->input.len - subj->pos, &after_char);
  if (len == -1) {
    after_char = 10;
  }
  left_flanking = numdelims > 0 && !cmark_utf8proc_is_space(after_char) &&
                  !(cmark_utf8proc_is_punctuation(after_char) &&
                    !cmark_utf8proc_is_space(before_char) &&
                    !cmark_utf8proc_is_punctuation(before_char));
  right_flanking = numdelims > 0 && !cmark_utf8proc_is_space(before_char) &&
                   !(cmark_utf8proc_is_punctuation(before_char) &&
                     !cmark_utf8proc_is_space(after_char) &&
                     !cmark_utf8proc_is_punctuation(after_char));
  if (c == '_') {
    *can_open = left_flanking &&
                (!right_flanking || cmark_utf8proc_is_punctuation(before_char));
    *can_close = right_flanking &&
                 (!left_flanking || cmark_utf8proc_is_punctuation(after_char));
  } else if (c == '\'' || c == '"') {
    *can_open = left_flanking && !right_flanking;
    *can_close = right_flanking;
  } else {
    *can_open = left_flanking;
    *can_close = right_flanking;
  }
  return numdelims;
}

/*
static void print_delimiters(subject *subj)
{
        delimiter *delim;
        delim = subj->last_delim;
        while (delim != NULL) {
                printf("Item at stack pos %p, text pos %d: %d %d %d next(%p)
prev(%p)\n",
                       (void*)delim, delim->position, delim->delim_char,
                       delim->can_open, delim->can_close,
                       (void*)delim->next, (void*)delim->previous);
                delim = delim->previous;
        }
}
*/

static void remove_delimiter(subject *subj, delimiter *delim) {
  if (delim == NULL)
    return;
  if (delim->next == NULL) {
    // end of list:
    assert(delim == subj->last_delim);
    subj->last_delim = delim->previous;
  } else {
    delim->next->previous = delim->previous;
  }
  if (delim->previous != NULL) {
    delim->previous->next = delim->next;
  }
  free(delim);
}

static void push_delimiter(subject *subj, unsigned char c, bool can_open,
                           bool can_close, cmark_node *inl_text) {
  delimiter *delim = (delimiter *)malloc(sizeof(delimiter));
  if (delim == NULL) {
    return;
  }
  delim->delim_char = c;
  delim->can_open = can_open;
  delim->can_close = can_close;
  delim->inl_text = inl_text;
  delim->previous = subj->last_delim;
  delim->next = NULL;
  if (delim->previous != NULL) {
    delim->previous->next = delim;
  }
  delim->position = subj->pos;
  delim->active = true;
  subj->last_delim = delim;
}

// Assumes the subject has a c at the current position.
static cmark_node *handle_delim(subject *subj, unsigned char c, bool smart) {
  bufsize_t numdelims;
  cmark_node *inl_text;
  bool can_open, can_close;
  cmark_chunk contents;

  numdelims = scan_delims(subj, c, &can_open, &can_close);

  if (c == '\'' && smart) {
    contents = cmark_chunk_literal(RIGHTSINGLEQUOTE);
  } else if (c == '"' && smart) {
    contents =
        cmark_chunk_literal(can_close ? RIGHTDOUBLEQUOTE : LEFTDOUBLEQUOTE);
  } else {
    contents = cmark_chunk_dup(&subj->input, subj->pos - numdelims, numdelims);
  }

  inl_text = make_str(contents);

  if ((can_open || can_close) && (!(c == '\'' || c == '"') || smart)) {
    push_delimiter(subj, c, can_open, can_close, inl_text);
  }

  return inl_text;
}

// Assumes we have a hyphen at the current position.
static cmark_node *handle_hyphen(subject *subj, bool smart) {
  int startpos = subj->pos;

  advance(subj);

  if (!smart || peek_char(subj) != '-') {
    return make_str(cmark_chunk_literal("-"));
  }

  while (smart && peek_char(subj) == '-') {
    advance(subj);
  }

  int numhyphens = subj->pos - startpos;
  int en_count = 0;
  int em_count = 0;
  int i;
  cmark_strbuf buf = GH_BUF_INIT;

  if (numhyphens % 3 == 0) { // if divisible by 3, use all em dashes
    em_count = numhyphens / 3;
  } else if (numhyphens % 2 == 0) { // if divisible by 2, use all en dashes
    en_count = numhyphens / 2;
  } else if (numhyphens % 3 == 2) { // use one en dash at end
    en_count = 1;
    em_count = (numhyphens - 2) / 3;
  } else { // use two en dashes at the end
    en_count = 2;
    em_count = (numhyphens - 4) / 3;
  }

  for (i = em_count; i > 0; i--) {
    cmark_strbuf_puts(&buf, EMDASH);
  }

  for (i = en_count; i > 0; i--) {
    cmark_strbuf_puts(&buf, ENDASH);
  }

  return make_str(cmark_chunk_buf_detach(&buf));
}

// Assumes we have a period at the current position.
static cmark_node *handle_period(subject *subj, bool smart) {
  advance(subj);
  if (smart && peek_char(subj) == '.') {
    advance(subj);
    if (peek_char(subj) == '.') {
      advance(subj);
      return make_str(cmark_chunk_literal(ELLIPSES));
    } else {
      return make_str(cmark_chunk_literal(".."));
    }
  } else {
    return make_str(cmark_chunk_literal("."));
  }
}

static void process_emphasis(subject *subj, delimiter *stack_bottom) {
  delimiter *closer = subj->last_delim;
  delimiter *opener;
  delimiter *old_closer;
  bool opener_found;
  delimiter *openers_bottom[128];

  // initialize openers_bottom:
  openers_bottom['*'] = stack_bottom;
  openers_bottom['_'] = stack_bottom;
  openers_bottom['\''] = stack_bottom;
  openers_bottom['"'] = stack_bottom;

  // move back to first relevant delim.
  while (closer != NULL && closer->previous != stack_bottom) {
    closer = closer->previous;
  }

  // now move forward, looking for closers, and handling each
  while (closer != NULL) {
    if (closer->can_close &&
        (closer->delim_char == '*' || closer->delim_char == '_' ||
         closer->delim_char == '"' || closer->delim_char == '\'')) {
      // Now look backwards for first matching opener:
      opener = closer->previous;
      opener_found = false;
      while (opener != NULL && opener != stack_bottom &&
             opener != openers_bottom[closer->delim_char]) {
        if (opener->delim_char == closer->delim_char && opener->can_open) {
          opener_found = true;
          break;
        }
        opener = opener->previous;
      }
      old_closer = closer;
      if (closer->delim_char == '*' || closer->delim_char == '_') {
        if (opener_found) {
          closer = S_insert_emph(subj, opener, closer);
        } else {
          closer = closer->next;
        }
      } else if (closer->delim_char == '\'') {
        cmark_chunk_free(&closer->inl_text->as.literal);
        closer->inl_text->as.literal = cmark_chunk_literal(RIGHTSINGLEQUOTE);
        if (opener_found) {
          cmark_chunk_free(&opener->inl_text->as.literal);
          opener->inl_text->as.literal = cmark_chunk_literal(LEFTSINGLEQUOTE);
        }
        closer = closer->next;
      } else if (closer->delim_char == '"') {
        cmark_chunk_free(&closer->inl_text->as.literal);
        closer->inl_text->as.literal = cmark_chunk_literal(RIGHTDOUBLEQUOTE);
        if (opener_found) {
          cmark_chunk_free(&opener->inl_text->as.literal);
          opener->inl_text->as.literal = cmark_chunk_literal(LEFTDOUBLEQUOTE);
        }
        closer = closer->next;
      }
      if (!opener_found) {
        // set lower bound for future searches for openers:
        openers_bottom[old_closer->delim_char] = old_closer->previous;
        if (!old_closer->can_open) {
          // we can remove a closer that can't be an
          // opener, once we've seen there's no
          // matching opener:
          remove_delimiter(subj, old_closer);
        }
      }
    } else {
      closer = closer->next;
    }
  }
  // free all delimiters in list until stack_bottom:
  while (subj->last_delim != stack_bottom) {
    remove_delimiter(subj, subj->last_delim);
  }
}

static delimiter *S_insert_emph(subject *subj, delimiter *opener,
                                delimiter *closer) {
  delimiter *delim, *tmp_delim;
  bufsize_t use_delims;
  cmark_node *opener_inl = opener->inl_text;
  cmark_node *closer_inl = closer->inl_text;
  bufsize_t opener_num_chars = opener_inl->as.literal.len;
  bufsize_t closer_num_chars = closer_inl->as.literal.len;
  cmark_node *tmp, *emph, *first_child, *last_child;

  // calculate the actual number of characters used from this closer
  if (closer_num_chars < 3 || opener_num_chars < 3) {
    use_delims = closer_num_chars <= opener_num_chars ? closer_num_chars
                                                      : opener_num_chars;
  } else { // closer and opener both have >= 3 characters
    use_delims = closer_num_chars % 2 == 0 ? 2 : 1;
  }

  // remove used characters from associated inlines.
  opener_num_chars -= use_delims;
  closer_num_chars -= use_delims;
  opener_inl->as.literal.len = opener_num_chars;
  closer_inl->as.literal.len = closer_num_chars;

  // free delimiters between opener and closer
  delim = closer->previous;
  while (delim != NULL && delim != opener) {
    tmp_delim = delim->previous;
    remove_delimiter(subj, delim);
    delim = tmp_delim;
  }

  first_child = opener_inl->next;
  last_child = closer_inl->prev;

  // if opener has 0 characters, remove it and its associated inline
  if (opener_num_chars == 0) {
    // replace empty opener inline with emph
    cmark_chunk_free(&(opener_inl->as.literal));
    emph = opener_inl;
    emph->type = use_delims == 1 ? CMARK_NODE_EMPH : CMARK_NODE_STRONG;
    // remove opener from list
    remove_delimiter(subj, opener);
  } else {
    // create new emph or strong, and splice it in to our inlines
    // between the opener and closer
    emph = use_delims == 1 ? make_emph() : make_strong();
    emph->parent = opener_inl->parent;
    emph->prev = opener_inl;
    opener_inl->next = emph;
  }

  // push children below emph
  emph->next = closer_inl;
  closer_inl->prev = emph;
  emph->first_child = first_child;
  emph->last_child = last_child;

  // fix children pointers
  first_child->prev = NULL;
  last_child->next = NULL;
  for (tmp = first_child; tmp != NULL; tmp = tmp->next) {
    tmp->parent = emph;
  }

  // if closer has 0 characters, remove it and its associated inline
  if (closer_num_chars == 0) {
    // remove empty closer inline
    cmark_node_free(closer_inl);
    // remove closer from list
    tmp_delim = closer->next;
    remove_delimiter(subj, closer);
    closer = tmp_delim;
  }

  return closer;
}

// Parse backslash-escape or just a backslash, returning an inline.
static cmark_node *handle_backslash(subject *subj) {
  advance(subj);
  unsigned char nextchar = peek_char(subj);
  if (cmark_ispunct(
          nextchar)) { // only ascii symbols and newline can be escaped
    advance(subj);
    return make_str(cmark_chunk_dup(&subj->input, subj->pos - 1, 1));
  } else if (!is_eof(subj) && skip_line_end(subj)) {
    return make_linebreak();
  } else {
    return make_str(cmark_chunk_literal("\\"));
  }
}

// Parse an entity or a regular "&" string.
// Assumes the subject has an '&' character at the current position.
static cmark_node *handle_entity(subject *subj) {
  cmark_strbuf ent = GH_BUF_INIT;
  bufsize_t len;

  advance(subj);

  len = houdini_unescape_ent(&ent, subj->input.data + subj->pos,
                             subj->input.len - subj->pos);

  if (len == 0)
    return make_str(cmark_chunk_literal("&"));

  subj->pos += len;
  return make_str(cmark_chunk_buf_detach(&ent));
}

// Clean a URL: remove surrounding whitespace and surrounding <>,
// and remove \ that escape punctuation.
cmark_chunk cmark_clean_url(cmark_chunk *url) {
  cmark_strbuf buf = GH_BUF_INIT;

  cmark_chunk_trim(url);

  if (url->len == 0) {
    cmark_chunk result = CMARK_CHUNK_EMPTY;
    return result;
  }

  if (url->data[0] == '<' && url->data[url->len - 1] == '>') {
    houdini_unescape_html_f(&buf, url->data + 1, url->len - 2);
  } else {
    houdini_unescape_html_f(&buf, url->data, url->len);
  }

  cmark_strbuf_unescape(&buf);
  return cmark_chunk_buf_detach(&buf);
}

cmark_chunk cmark_clean_title(cmark_chunk *title) {
  cmark_strbuf buf = GH_BUF_INIT;
  unsigned char first, last;

  if (title->len == 0) {
    cmark_chunk result = CMARK_CHUNK_EMPTY;
    return result;
  }

  first = title->data[0];
  last = title->data[title->len - 1];

  // remove surrounding quotes if any:
  if ((first == '\'' && last == '\'') || (first == '(' && last == ')') ||
      (first == '"' && last == '"')) {
    houdini_unescape_html_f(&buf, title->data + 1, title->len - 2);
  } else {
    houdini_unescape_html_f(&buf, title->data, title->len);
  }

  cmark_strbuf_unescape(&buf);
  return cmark_chunk_buf_detach(&buf);
}

// Parse an autolink or HTML tag.
// Assumes the subject has a '<' character at the current position.
static cmark_node *handle_pointy_brace(subject *subj) {
  bufsize_t matchlen = 0;
  cmark_chunk contents;

  advance(subj); // advance past first <

  // first try to match a URL autolink
  matchlen = scan_autolink_uri(&subj->input, subj->pos);
  if (matchlen > 0) {
    contents = cmark_chunk_dup(&subj->input, subj->pos, matchlen - 1);
    subj->pos += matchlen;

    return make_autolink(contents, 0);
  }

  // next try to match an email autolink
  matchlen = scan_autolink_email(&subj->input, subj->pos);
  if (matchlen > 0) {
    contents = cmark_chunk_dup(&subj->input, subj->pos, matchlen - 1);
    subj->pos += matchlen;

    return make_autolink(contents, 1);
  }

  // finally, try to match an html tag
  matchlen = scan_html_tag(&subj->input, subj->pos);
  if (matchlen > 0) {
    contents = cmark_chunk_dup(&subj->input, subj->pos - 1, matchlen + 1);
    subj->pos += matchlen;
    return make_raw_html(contents);
  }

  // if nothing matches, just return the opening <:
  return make_str(cmark_chunk_literal("<"));
}

// Parse a link label.  Returns 1 if successful.
// Note:  unescaped brackets are not allowed in labels.
// The label begins with `[` and ends with the first `]` character
// encountered.  Backticks in labels do not start code spans.
static int link_label(subject *subj, cmark_chunk *raw_label) {
  bufsize_t startpos = subj->pos;
  int length = 0;
  unsigned char c;

  // advance past [
  if (peek_char(subj) == '[') {
    advance(subj);
  } else {
    return 0;
  }

  while ((c = peek_char(subj)) && c != '[' && c != ']') {
    if (c == '\\') {
      advance(subj);
      length++;
      if (cmark_ispunct(peek_char(subj))) {
        advance(subj);
        length++;
      }
    } else {
      advance(subj);
      length++;
    }
    if (length > MAX_LINK_LABEL_LENGTH) {
      goto noMatch;
    }
  }

  if (c == ']') { // match found
    *raw_label =
        cmark_chunk_dup(&subj->input, startpos + 1, subj->pos - (startpos + 1));
    cmark_chunk_trim(raw_label);
    advance(subj); // advance past ]
    return 1;
  }

noMatch:
  subj->pos = startpos; // rewind
  return 0;
}

// Return a link, an image, or a literal close bracket.
static cmark_node *handle_close_bracket(subject *subj, cmark_node *parent) {
  bufsize_t initial_pos;
  bufsize_t starturl, endurl, starttitle, endtitle, endall;
  bufsize_t n;
  bufsize_t sps;
  cmark_reference *ref;
  bool is_image = false;
  cmark_chunk url_chunk, title_chunk;
  cmark_chunk url, title;
  delimiter *opener;
  cmark_node *link_text;
  cmark_node *inl;
  cmark_chunk raw_label;
  int found_label;

  advance(subj); // advance past ]
  initial_pos = subj->pos;

  // look through list of delimiters for a [ or !
  opener = subj->last_delim;
  while (opener) {
    if (opener->delim_char == '[' || opener->delim_char == '!') {
      break;
    }
    opener = opener->previous;
  }

  if (opener == NULL) {
    return make_str(cmark_chunk_literal("]"));
  }

  if (!opener->active) {
    // take delimiter off stack
    remove_delimiter(subj, opener);
    return make_str(cmark_chunk_literal("]"));
  }

  // If we got here, we matched a potential link/image text.
  is_image = opener->delim_char == '!';
  link_text = opener->inl_text->next;

  // Now we check to see if it's a link/image.

  // First, look for an inline link.
  if (peek_char(subj) == '(' &&
      ((sps = scan_spacechars(&subj->input, subj->pos + 1)) > -1) &&
      ((n = scan_link_url(&subj->input, subj->pos + 1 + sps)) > -1)) {

    // try to parse an explicit link:
    starturl = subj->pos + 1 + sps; // after (
    endurl = starturl + n;
    starttitle = endurl + scan_spacechars(&subj->input, endurl);

    // ensure there are spaces btw url and title
    endtitle = (starttitle == endurl)
                   ? starttitle
                   : starttitle + scan_link_title(&subj->input, starttitle);

    endall = endtitle + scan_spacechars(&subj->input, endtitle);

    if (peek_at(subj, endall) == ')') {
      subj->pos = endall + 1;

      url_chunk = cmark_chunk_dup(&subj->input, starturl, endurl - starturl);
      title_chunk =
          cmark_chunk_dup(&subj->input, starttitle, endtitle - starttitle);
      url = cmark_clean_url(&url_chunk);
      title = cmark_clean_title(&title_chunk);
      cmark_chunk_free(&url_chunk);
      cmark_chunk_free(&title_chunk);
      goto match;

    } else {
      goto noMatch;
    }
  }

  // Next, look for a following [link label] that matches in refmap.
  // skip spaces
  raw_label = cmark_chunk_literal("");
  found_label = link_label(subj, &raw_label);
  if (!found_label || raw_label.len == 0) {
    cmark_chunk_free(&raw_label);
    raw_label = cmark_chunk_dup(&subj->input, opener->position,
                                initial_pos - opener->position - 1);
  }

  if (!found_label) {
    // If we have a shortcut reference link, back up
    // to before the spacse we skipped.
    subj->pos = initial_pos;
  }

  ref = cmark_reference_lookup(subj->refmap, &raw_label);
  cmark_chunk_free(&raw_label);

  if (ref != NULL) { // found
    url = chunk_clone(&ref->url);
    title = chunk_clone(&ref->title);
    goto match;
  } else {
    goto noMatch;
  }

noMatch:
  // If we fall through to here, it means we didn't match a link:
  remove_delimiter(subj, opener); // remove this opener from delimiter list
  subj->pos = initial_pos;
  return make_str(cmark_chunk_literal("]"));

match:
  inl = opener->inl_text;
  inl->type = is_image ? CMARK_NODE_IMAGE : CMARK_NODE_LINK;
  cmark_chunk_free(&inl->as.literal);
  inl->first_child = link_text;
  process_emphasis(subj, opener);
  inl->as.link.url = url;
  inl->as.link.title = title;
  inl->next = NULL;
  if (link_text) {
    cmark_node *tmp;
    link_text->prev = NULL;
    for (tmp = link_text; tmp->next != NULL; tmp = tmp->next) {
      tmp->parent = inl;
    }
    tmp->parent = inl;
    inl->last_child = tmp;
  }
  parent->last_child = inl;

  // Now, if we have a link, we also want to deactivate earlier link
  // delimiters. (This code can be removed if we decide to allow links
  // inside links.)
  remove_delimiter(subj, opener);
  if (!is_image) {
    opener = subj->last_delim;
    while (opener != NULL) {
      if (opener->delim_char == '[') {
        if (!opener->active) {
          break;
        } else {
          opener->active = false;
        }
      }
      opener = opener->previous;
    }
  }

  return NULL;
}

// Parse a hard or soft linebreak, returning an inline.
// Assumes the subject has a cr or newline at the current position.
static cmark_node *handle_newline(subject *subj) {
  bufsize_t nlpos = subj->pos;
  // skip over cr, crlf, or lf:
  if (peek_at(subj, subj->pos) == '\r') {
    advance(subj);
  }
  if (peek_at(subj, subj->pos) == '\n') {
    advance(subj);
  }
  // skip spaces at beginning of line
  skip_spaces(subj);
  if (nlpos > 1 && peek_at(subj, nlpos - 1) == ' ' &&
      peek_at(subj, nlpos - 2) == ' ') {
    return make_linebreak();
  } else {
    return make_softbreak();
  }
}

static bufsize_t subject_find_special_char(subject *subj, int options) {
  // "\r\n\\`&_*[]<!"
  static const int8_t SPECIAL_CHARS[256] = {
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

  // " ' . -
  static const char SMART_PUNCT_CHARS[] = {
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  };

  bufsize_t n = subj->pos + 1;

  while (n < subj->input.len) {
    if (SPECIAL_CHARS[subj->input.data[n]])
      return n;
    if (options & CMARK_OPT_SMART && SMART_PUNCT_CHARS[subj->input.data[n]])
      return n;
    n++;
  }

  return subj->input.len;
}

// Parse an inline, advancing subject, and add it as a child of parent.
// Return 0 if no inline can be parsed, 1 otherwise.
static int parse_inline(subject *subj, cmark_node *parent, int options) {
  cmark_node *new_inl = NULL;
  cmark_chunk contents;
  unsigned char c;
  bufsize_t endpos;
  c = peek_char(subj);
  if (c == 0) {
    return 0;
  }
  switch (c) {
  case '\r':
  case '\n':
    new_inl = handle_newline(subj);
    break;
  case '`':
    new_inl = handle_backticks(subj);
    break;
  case '\\':
    new_inl = handle_backslash(subj);
    break;
  case '&':
    new_inl = handle_entity(subj);
    break;
  case '<':
    new_inl = handle_pointy_brace(subj);
    break;
  case '*':
  case '_':
  case '\'':
  case '"':
    new_inl = handle_delim(subj, c, (options & CMARK_OPT_SMART) != 0);
    break;
  case '-':
    new_inl = handle_hyphen(subj, (options & CMARK_OPT_SMART) != 0);
    break;
  case '.':
    new_inl = handle_period(subj, (options & CMARK_OPT_SMART) != 0);
    break;
  case '[':
    advance(subj);
    new_inl = make_str(cmark_chunk_literal("["));
    push_delimiter(subj, '[', true, false, new_inl);
    break;
  case ']':
    new_inl = handle_close_bracket(subj, parent);
    break;
  case '!':
    advance(subj);
    if (peek_char(subj) == '[') {
      advance(subj);
      new_inl = make_str(cmark_chunk_literal("!["));
      push_delimiter(subj, '!', false, true, new_inl);
    } else {
      new_inl = make_str(cmark_chunk_literal("!"));
    }
    break;
  default:
    endpos = subject_find_special_char(subj, options);
    contents = cmark_chunk_dup(&subj->input, subj->pos, endpos - subj->pos);
    subj->pos = endpos;

    // if we're at a newline, strip trailing spaces.
    if (S_is_line_end_char(peek_char(subj))) {
      cmark_chunk_rtrim(&contents);
    }

    new_inl = make_str(contents);
  }
  if (new_inl != NULL) {
    cmark_node_append_child(parent, new_inl);
  }

  return 1;
}

// Parse inlines from parent's string_content, adding as children of parent.
extern void cmark_parse_inlines(cmark_node *parent, cmark_reference_map *refmap,
                                int options) {
  subject subj;
  subject_from_buf(&subj, &parent->string_content, refmap);
  cmark_chunk_rtrim(&subj.input);

  while (!is_eof(&subj) && parse_inline(&subj, parent, options))
    ;

  process_emphasis(&subj, NULL);
}

// Parse zero or more space characters, including at most one newline.
static void spnl(subject *subj) {
  skip_spaces(subj);
  if (skip_line_end(subj)) {
    skip_spaces(subj);
  }
}

// Parse reference.  Assumes string begins with '[' character.
// Modify refmap if a reference is encountered.
// Return 0 if no reference found, otherwise position of subject
// after reference is parsed.
bufsize_t cmark_parse_reference_inline(cmark_strbuf *input,
                                       cmark_reference_map *refmap) {
  subject subj;

  cmark_chunk lab;
  cmark_chunk url;
  cmark_chunk title;

  bufsize_t matchlen = 0;
  bufsize_t beforetitle;

  subject_from_buf(&subj, input, NULL);

  // parse label:
  if (!link_label(&subj, &lab) || lab.len == 0)
    return 0;

  // colon:
  if (peek_char(&subj) == ':') {
    advance(&subj);
  } else {
    return 0;
  }

  // parse link url:
  spnl(&subj);
  matchlen = scan_link_url(&subj.input, subj.pos);
  if (matchlen) {
    url = cmark_chunk_dup(&subj.input, subj.pos, matchlen);
    subj.pos += matchlen;
  } else {
    return 0;
  }

  // parse optional link_title
  beforetitle = subj.pos;
  spnl(&subj);
  matchlen = scan_link_title(&subj.input, subj.pos);
  if (matchlen) {
    title = cmark_chunk_dup(&subj.input, subj.pos, matchlen);
    subj.pos += matchlen;
  } else {
    subj.pos = beforetitle;
    title = cmark_chunk_literal("");
  }

  // parse final spaces and newline:
  skip_spaces(&subj);
  if (!skip_line_end(&subj)) {
    if (matchlen) { // try rewinding before title
      subj.pos = beforetitle;
      skip_spaces(&subj);
      if (!skip_line_end(&subj)) {
        return 0;
      }
    } else {
      return 0;
    }
  }
  // insert reference into refmap
  cmark_reference_create(refmap, &lab, &url, &title);
  return subj.pos;
}
