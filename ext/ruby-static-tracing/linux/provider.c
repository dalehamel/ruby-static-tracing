#include "provider.h"

static const rb_data_type_t
static_tracing_provider_type;
/*
  Wraps ProviderInit from libstapsdt
*/
VALUE
provider_initialize(VALUE self, VALUE id)
{

  static_tracing_provider_t *provider = NULL;

  TypedData_Get_Struct(self, static_tracing_provider_t, &static_tracing_provider_type, provider);
rb_hash_new();

  provider->tracepoints = rb_hash_new();
// SDTProvider_t *providerInit(const char *name);
  return Qnil;
}

/*
  Wraps providerAddProbe in libstapsdt
*/
VALUE
provider_add_tracepoint(VALUE self, VALUE name, VALUE vargs)
{
  return Qnil;
}

/*
  Wraps providerLoad from libstapsdt
*/
VALUE
provider_enable(VALUE self)
{
// int providerLoad(SDTProvider_t *provider);
  return Qnil;
}

/*
  Wraps providerUnload from libstapsdt
*/
VALUE
provider_disable(VALUE self)
{
// int providerUnload(SDTProvider_t *provider);
  return Qnil;
}

/*
  Wraps providerUnload from libstapsdt
*/
VALUE
provider_destroy(VALUE self)
{
// void providerDestroy(SDTProvider_t *provider);
  return Qnil;
}

// Allocate a static_tracing_provider_type struct for ruby memory management
VALUE
static_tracing_provider_alloc(VALUE klass)
{
  return Qnil;
}

static inline void
static_tracing_provider_mark(void *ptr)
{
  /* noop */
}

static inline void
static_tracing_provider_free(void *ptr)
{
  static_tracing_provider_t *res = (static_tracing_provider_t *) ptr;
  //if (res->name) {
  //  free(res->name);
  //  res->name = NULL;
  //}
  xfree(res);
}

static inline size_t
static_tracing_provider_memsize(const void *ptr)
{
  return sizeof(static_tracing_provider_t);
}

static const rb_data_type_t
static_tracing_provider_type = {
  "static_tracing_provider",
  {
    static_tracing_provider_mark,
    static_tracing_provider_free,
    static_tracing_provider_memsize
  },
  NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
};
