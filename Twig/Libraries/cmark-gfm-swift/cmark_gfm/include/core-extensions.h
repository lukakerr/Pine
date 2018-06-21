#ifndef CORE_EXTENSIONS_H
#define CORE_EXTENSIONS_H

#ifdef __cplusplus
extern "C" {
#endif

#include "cmark_extension_api.h"
#include "cmarkextensions_export.h"
#include <stdint.h>

CMARKEXTENSIONS_EXPORT
void core_extensions_ensure_registered(void);

CMARKEXTENSIONS_EXPORT
uint16_t cmarkextensions_get_table_columns(cmark_node *node);

CMARKEXTENSIONS_EXPORT
uint8_t *cmarkextensions_get_table_alignments(cmark_node *node);

extern cmark_node_type CMARK_NODE_TABLE;
extern cmark_node_type CMARK_NODE_TABLE_ROW;
extern cmark_node_type CMARK_NODE_TABLE_CELL;
extern cmark_node_type CMARK_NODE_STRIKETHROUGH;
extern cmark_node_type CMARK_NODE_MENTION;
extern const char *cmark_node_get_mention_login(cmark_node *node);
extern cmark_node_type CMARK_NODE_CHECKBOX;
extern int cmark_node_get_checkbox_checked(cmark_node *node);
extern int cmark_node_get_checkbox_location(cmark_node *node);
extern int cmark_node_get_checkbox_length(cmark_node *node);

#ifdef __cplusplus
}
#endif

#endif
