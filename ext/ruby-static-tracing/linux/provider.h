/*
For core static tracing functions exposed directly to ruby.
Functions here are associated with rubyland operations.
*/
#ifndef STATIC_TRACING_PROVIDER_H
#define STATIC_TRACING_PROVIDER_H

#include <ruby.h>
// Include libstapsdt.h to wrap
#include <libstapsdt.h>

#include "ruby_static_tracing.h"
#include "tracepoint.h"

typedef struct {
  char *name;
  SDTProvider_t *sdt_provider;
  VALUE tracepoints;
} static_tracing_provider_t;

/*
 * call-seq:
 *    StaticTracing::Provider.new(id) -> provider
 *
 * Creates a new Provider.
 */
VALUE
provider_initialize(VALUE self, VALUE id);

// /*
//  * call-seq:
//  *    provider.tracepoints() -> []
//  *
//  * Lists the tracepoints associated with this provider
//  */
// VALUE
// provider_tracepoints(VALUE self);
// FIXME probably implement this by getting values in dict

/*
 * call-seq:
 *    provider.add_tracepoint(name, *vargs) -> tracepoint
 *
 * Registers a new tracepoint with this provider
 *
 * Return an instance of a StaticTracing::Tracepoint object
 */
VALUE
provider_add_tracepoint(VALUE self, VALUE name, VALUE vargs);

/*
 * call-seq:
 *    provider.enable() -> true
 *
 * Enable this provider
 *
 * Return true if the enable operation succeeded
 */
VALUE
provider_enable(VALUE self);

/*
 * call-seq:
 *    provider.disable() -> true
 *
 * Disable this provider
 *
 * Return true if the disable operation succeeded
 */
VALUE
provider_disable(VALUE self);
/*
 * call-seq:
 *    provider.destroy() -> true
 *
 * Destroys this provider.
 *
 * Return true if the destory operation succeeded
 */
VALUE
provider_destroy(VALUE self);

// Allocate a static_tracing_provider_type struct for ruby memory management
VALUE
static_tracing_provider_alloc(VALUE klass);

SDTProbe_t
*provider_add_tracepoint_internal(VALUE self, const char* name, VALUE vargs);

#endif //STATIC_TRACING_PROVIDER_H
