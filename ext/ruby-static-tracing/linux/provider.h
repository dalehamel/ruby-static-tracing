#ifndef STATIC_TRACING_PROVIDER_H
#define STATIC_TRACING_PROVIDER_H

// Include libstapsdt.h to wrap
#include <libstapsdt.h> // FIXME use local

#include "ruby_static_tracing.h"
#include "types.h"

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

/*
 * call-seq:
 *    provider.path() -> string
 *
 * Get a path to this provider, if the platform supports it
 *
 * Returns string for path, or empty string if failed
 */
VALUE
provider_path(VALUE self);

// Allocate a static_tracing_provider_type struct for ruby memory management
VALUE
static_tracing_provider_alloc(VALUE klass);

SDTProbe_t *provider_add_tracepoint_internal(VALUE self, const char *name,
                                             int argc,
                                             Tracepoint_arg_types *args);

#endif // STATIC_TRACING_PROVIDER_H
