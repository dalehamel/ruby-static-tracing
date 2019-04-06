/*
For core static tracing functions exposed directly to ruby.
Functions here are associated with rubyland operations.
*/
#ifndef STATIC_TRACING_PROVIDER_H
#define STATIC_TRACING_PROVIDER_H

#ifndef STATIC_TRACING_USDT_INCLUDED
#define STATIC_TRACING_USDT_INCLUDED
#include "usdt.h" // FIXME fork this to add a proper include guard to the header itself
#endif //STATIC_TRACING_USDT_INCLUDED

#include "ruby_static_tracing.h"
#include "types.h"
#include "tracepoint.h"

typedef struct {
  char *name;
//  SDTProvider_t *sdt_provider;
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

//SDTProbe_t
//*provider_add_tracepoint_internal(VALUE self, const char* name, int argc, Tracepoint_arg_types *args);

#endif //STATIC_TRACING_PROVIDER_H
