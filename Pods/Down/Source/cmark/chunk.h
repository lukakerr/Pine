#ifndef CMARK_CHUNK_H
#define CMARK_CHUNK_H

#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "cmark_ctype.h"
#include "buffer.h"

#define CMARK_CHUNK_EMPTY                                                      \
  { NULL, 0, 0 }

typedef struct {
  unsigned char *data;
  bufsize_t len;
  bufsize_t alloc; // also implies a NULL-terminated string
} cmark_chunk;

static CMARK_INLINE void cmark_chunk_free(cmark_chunk *c) {
  if (c->alloc)
    free(c->data);

  c->data = NULL;
  c->alloc = 0;
  c->len = 0;
}

static CMARK_INLINE void cmark_chunk_ltrim(cmark_chunk *c) {
  assert(!c->alloc);

  while (c->len && cmark_isspace(c->data[0])) {
    c->data++;
    c->len--;
  }
}

static CMARK_INLINE void cmark_chunk_rtrim(cmark_chunk *c) {
  while (c->len > 0) {
    if (!cmark_isspace(c->data[c->len - 1]))
      break;

    c->len--;
  }
}

static CMARK_INLINE void cmark_chunk_trim(cmark_chunk *c) {
  cmark_chunk_ltrim(c);
  cmark_chunk_rtrim(c);
}

static CMARK_INLINE bufsize_t cmark_chunk_strchr(cmark_chunk *ch, int c,
                                                 bufsize_t offset) {
  const unsigned char *p =
      (unsigned char *)memchr(ch->data + offset, c, ch->len - offset);
  return p ? (bufsize_t)(p - ch->data) : ch->len;
}

static CMARK_INLINE const char *cmark_chunk_to_cstr(cmark_chunk *c) {
  unsigned char *str;

  if (c->alloc) {
    return (char *)c->data;
  }
  str = (unsigned char *)malloc(c->len + 1);
  if (str != NULL) {
    if (c->len > 0) {
      memcpy(str, c->data, c->len);
    }
    str[c->len] = 0;
  }
  c->data = str;
  c->alloc = 1;

  return (char *)str;
}

static CMARK_INLINE void cmark_chunk_set_cstr(cmark_chunk *c, const char *str) {
  if (c->alloc) {
    free(c->data);
  }
  if (str == NULL) {
    c->len = 0;
    c->data = NULL;
    c->alloc = 0;
  } else {
    c->len = cmark_strbuf_safe_strlen(str);
    c->data = (unsigned char *)malloc(c->len + 1);
    c->alloc = 1;
    memcpy(c->data, str, c->len + 1);
  }
}

static CMARK_INLINE cmark_chunk cmark_chunk_literal(const char *data) {
  bufsize_t len = data ? cmark_strbuf_safe_strlen(data) : 0;
  cmark_chunk c = {(unsigned char *)data, len, 0};
  return c;
}

static CMARK_INLINE cmark_chunk cmark_chunk_dup(const cmark_chunk *ch,
                                                bufsize_t pos, bufsize_t len) {
  cmark_chunk c = {ch->data + pos, len, 0};
  return c;
}

static CMARK_INLINE cmark_chunk cmark_chunk_buf_detach(cmark_strbuf *buf) {
  cmark_chunk c;

  c.len = buf->size;
  c.data = cmark_strbuf_detach(buf);
  c.alloc = 1;

  return c;
}

#endif
