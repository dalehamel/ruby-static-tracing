#include "tracepoint.h"

static const rb_data_type_t
static_tracing_tracepoint_type;

static const rb_data_type_t
static_tracing_provider_type;

VALUE
tracepoint_initialize(VALUE self, VALUE provider, VALUE name, VALUE vargs)
{
  static_tracing_tracepoint_t *tracepoint = NULL;
  static_tracing_provider_t *provider_inst = NULL;

// FIXME wrap provider_add_tracepoint
// Look up providers from global dict by provider name supplied or initialize provider with name
// provider_add_tracepoint(VALUE self, VALUE name) // FIXME add arg count and vargs tracepount arguments
  VALUE cStaticTracing, cProvider, cProviderInst;

  //// Get a handle to global provider list for lookup
  cStaticTracing = rb_const_get(rb_cObject, rb_intern("StaticTracing"));
  cProvider = rb_const_get(cStaticTracing, rb_intern("Provider"));
  cProviderInst = rb_funcall(cProvider, rb_intern("register"), 1, provider);

  TypedData_Get_Struct(cProviderInst, static_tracing_provider_t, &static_tracing_provider_type, provider_inst);

  providerAddProbe(provider_inst->sdt_provider, "foo", 0);
  // FIXME get argc from vargs using array methods

  // FIXME check providers is of type T_HASH
  // FIXME check if provider is a string or a provider instance
  // if it is a provider instance
  // just use it directly to construct the tracepoint
  // else if it is a string, look it up here
  // cProviderInst = rb_hash_aref(cProviders, provider);

  // If the provider instance is Qnil, then create a provider and store it in cProviders

  // Use the provider instance to call providerAddProbe
  // Store the resulting SDTProbe in static_tracepoint_type

  TypedData_Get_Struct(self, static_tracing_tracepoint_t, &static_tracing_tracepoint_type, tracepoint);


  //SDTProbe_t *providerAddProbe(SDTProvider_t *provider, const char *name, int argCount, ...);
  // SDTProbe_t *sdt_tracepoint = providerAddProbe(provider->sdt_provider, name, argc, vargs)
  //tracepoint->sdt_tracepoint = sdt_tracepoint;

  return self;
}

VALUE
tracepoint_fire(VALUE self, VALUE vargs)
{
// void probeFire(SDTProbe_t *probe, ...);
  return Qnil;
}

VALUE
tracepoint_enabled(VALUE self)
{
// int probeIsEnabled(SDTProbe_t *probe);
  return Qnil;
}

// Allocate a static_tracing_tracepoint_type struct for ruby memory management
VALUE
static_tracing_tracepoint_alloc(VALUE klass)
{
  static_tracing_tracepoint_t *res;
  VALUE obj = TypedData_Make_Struct(klass, static_tracing_tracepoint_t, &static_tracing_tracepoint_type, res);
  return obj;
}

static inline void
static_tracing_tracepoint_mark(void *ptr)
{
  /* noop */
}

static inline void
static_tracing_tracepoint_free(void *ptr)
{
  static_tracing_tracepoint_t *res = (static_tracing_tracepoint_t *) ptr;
  //if (res->name) {
  //  free(res->name);
  //  res->name = NULL;
  //}
  xfree(res);
}

static inline size_t
static_tracing_tracepoint_memsize(const void *ptr)
{
  return sizeof(static_tracing_provider_t);
}

//static const rb_data_type_t
//static_tracing_tracepoint_type = {
//  "static_tracing_tracepoint",
//  {
//    static_tracing_tracepoint_mark,
//    static_tracing_tracepoint_free,
//    static_tracing_tracepoint_memsize
//  },
//  NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
//};
