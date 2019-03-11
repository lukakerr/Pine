#include "wikilink.h"
#include "parser.h"
#include "render.h"

cmark_node_type CMARK_NODE_WIKILINK;

const char *cmark_node_get_wikilink(cmark_node *node) {
  if (node->type != CMARK_NODE_WIKILINK) {
    return NULL;
  }

  // str is of form [x|x]] where x could be empty
  const char* str = cmark_chunk_to_cstr(cmark_node_mem(node), (cmark_chunk *)node->as.opaque);

  const char* delim = "|";

  // Length of string without [ and ]
  unsigned long wikilinkLen = strlen(str) - 3;

  char* wikilink = calloc(wikilinkLen + 1, sizeof(char));
  if (!wikilink) {
    return NULL;
  }
  strncpy(wikilink, &str[1], wikilinkLen);

  // Get first string (the description) from seperated
  char* description = strsep(&wikilink, delim);

  // Description is empty
  if (description == NULL || strcmp(description, "") == 0) {
    return NULL;
  }

  unsigned long descLen = strlen(description);

  // Setup contents for return result
  char* contents = calloc(descLen, sizeof(char));

  char* link = strsep(&wikilink, delim);

  // Link is empty, so use description as link
  if (link == NULL || strcmp(link, "") == 0) {
    // Allocate contents to double description length + length of \"> + null terminator
    contents = realloc(contents, (descLen * 2) + 3);
    strcat(contents, description);
    strcat(contents, "\">");
    strcat(contents, description);
  } else {
    // Allocate contents to description length + link length
    // + length of \"> + null terminator
    contents = realloc(contents, descLen + strlen(link) + 3);
    strcat(contents, link);
    strcat(contents, "\">");
    strcat(contents, description);
  }

  return contents;
}

static cmark_node *match(cmark_syntax_extension *self, cmark_parser *parser,
                         cmark_node *parent, unsigned char character,
                         cmark_inline_parser *inline_parser) {
  if (character != '[')
    return NULL;

  cmark_chunk *chunk = cmark_inline_parser_get_chunk(inline_parser);
  uint8_t *data = chunk->data;
  size_t size = chunk->len;
  int start = cmark_inline_parser_get_offset(inline_parser);
  int at = start + 1;
  int end = at;

  if (start > 0 && data[start] != '[') {
    return NULL;
  }

  end++;

  // Read up until we see the first terminating ']'
  while (end < size && data[end] != ']') {
    end++;
  }

  // Try to consume the final two ']' characters
  for (int i = 0; i < 2; i++) {
    if (data[end] == ']') {
      end++;
    } else {
      return NULL;
    }
  }

  if (end == at) {
    return NULL;
  }

  cmark_node *node = cmark_node_new_with_mem(CMARK_NODE_WIKILINK, parser->mem);

  cmark_chunk *wikilink_chunk;
  node->as.opaque = wikilink_chunk = parser->mem->calloc(1, sizeof(cmark_chunk));
  wikilink_chunk->data = data + at;
  wikilink_chunk->len = end - at;

  cmark_inline_parser_set_offset(inline_parser, start + (end - start));
  cmark_node_set_syntax_extension(node, self);

  return node;
}

static void html_render(cmark_syntax_extension *extension,
                        cmark_html_renderer *renderer, cmark_node *node,
                        cmark_event_type ev_type, int options) {
  if (ev_type != CMARK_EVENT_ENTER) {
    return;
  }

  const char *contents = cmark_node_get_wikilink(node);

  if (contents == NULL) {
    return;
  }

  cmark_strbuf *html = renderer->html;
  cmark_strbuf_puts(html, "<a href=\"");
  cmark_strbuf_puts(html, contents);
  cmark_strbuf_puts(html, "</a>");
}

static const char *get_type_string(cmark_syntax_extension *extension,
                                   cmark_node *node) {
  return node->type == CMARK_NODE_WIKILINK ? "wikilink" : "<unknown>";
}

static int can_contain(cmark_syntax_extension *extension, cmark_node *node,
                       cmark_node_type child_type) {
  if (node->type != CMARK_NODE_WIKILINK)
    return false;

  return CMARK_NODE_TYPE_INLINE_P(child_type);
}

static void opaque_free(cmark_syntax_extension *self, cmark_mem *mem, cmark_node *node) {
  if (node->type == CMARK_NODE_WIKILINK) {
    mem->free(node->as.opaque);
  }
}

cmark_syntax_extension *create_wikilink_extension(void) {
  cmark_syntax_extension *self = cmark_syntax_extension_new("wikilink");
  cmark_llist *special_chars = NULL;

  cmark_syntax_extension_set_get_type_string_func(self, get_type_string);
  cmark_syntax_extension_set_can_contain_func(self, can_contain);
  cmark_syntax_extension_set_opaque_free_func(self, opaque_free);
  cmark_syntax_extension_set_html_render_func(self, html_render);

  CMARK_NODE_WIKILINK = cmark_syntax_extension_add_node(1);

  cmark_syntax_extension_set_match_inline_func(self, match);

  cmark_mem *mem = cmark_get_default_mem_allocator();
  special_chars = cmark_llist_append(mem, special_chars, (void *)'[');
  cmark_syntax_extension_set_special_inline_chars(self, special_chars);

  return self;
}

