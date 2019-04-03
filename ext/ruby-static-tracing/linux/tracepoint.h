/*
For core static tracing functions exposed directly to ruby.
Functions here are associated with rubyland operations.
*/
#ifndef STATIC_TRACING_TRACEPOINT_H
#define STATIC_TRACING_TRACEPOINT_H

#include <ruby.h>
// Include libstapsdt.h to wrap
#include <libstapsdt.h>
// Probably need to include provider.h to be able to initialize self

#include "ruby_static_tracing.h"

typedef struct {
  char *name;
  SDTProbe_t *sdt_tracepoint;
} static_tracing_tracepoint_t;

typedef enum TRACEPOINT_ARG_TYPES {
  Integer,
  String,
} Tracepoint_arg_types_enum;

/*
 * call-seq:
 *    StaticTracing::Tracepoint.new(provider, id, *vargs) -> tracepoint
 *
 * Creates a new tracepoint on a provider
 */
VALUE
tracepoint_initialize(VALUE self, VALUE provider, VALUE id, VALUE vargs);

/*
 * call-seq:
 *    tracepoint.fire(*vargs) -> true
 *
 * Fires data for the tracepoint to be probed
 */
VALUE
tracepoint_fire(VALUE self, VALUE vargs);

/*
 * call-seq:
 *    tracepoint.enabled? -> true
 *
 * Checks if the tracepoint is enabled, indicating it is being traced
 */
VALUE
tracepoint_enabled(VALUE self);

// Allocate a static_tracing_tracepoint_type struct for ruby memory management
VALUE
static_tracing_tracepoint_alloc(VALUE klass);

#endif //STATIC_TRACING_TRACEPOINT_H
