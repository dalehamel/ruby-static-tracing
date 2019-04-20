#ifndef STATIC_TRACING_PROVIDER_H
#define STATIC_TRACING_PROVIDER_H

#include "usdt.h"

#include "ruby_static_tracing.h"
#include "tracepoint.h"

typedef struct {
  char *name;
  usdt_provider_t *usdt_provider;
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

int provider_add_tracepoint_internal(VALUE self, usdt_probedef_t *probedef);

#endif // STATIC_TRACING_PROVIDER_H
