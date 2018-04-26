#ifndef CMARK_INLINES_H
#define CMARK_INLINES_H

#import "references.h"

#ifdef __cplusplus
extern "C" {
#endif

cmark_chunk cmark_clean_url(cmark_chunk *url);
cmark_chunk cmark_clean_title(cmark_chunk *title);

void cmark_parse_inlines(cmark_node *parent, cmark_reference_map *refmap,
                         int options);

bufsize_t cmark_parse_reference_inline(cmark_strbuf *input,
                                       cmark_reference_map *refmap);

#ifdef __cplusplus
}
#endif

#endif
