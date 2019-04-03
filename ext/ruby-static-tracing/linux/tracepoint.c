#include "tracepoint.h"
#include "provider.h"

static const rb_data_type_t
static_tracing_tracepoint_type;

static const char*
check_name_arg(VALUE provider);

static const char*
check_provider_arg(VALUE provider);

VALUE
tracepoint_initialize(VALUE self, VALUE provider, VALUE name, VALUE vargs)
{
  VALUE cStaticTracing, cProvider, cProviderInst;
  static_tracing_tracepoint_t *tracepoint = NULL;
  const char *c_name_str = NULL;
  const char *c_provider_str = NULL;

  c_name_str     = check_name_arg(name);
  c_provider_str = check_provider_arg(name);

  /// Get a handle to global provider list for lookup
  cStaticTracing = rb_const_get(rb_cObject, rb_intern("StaticTracing"));
  cProvider = rb_const_get(cStaticTracing, rb_intern("Provider"));
  cProviderInst = rb_funcall(cProvider, rb_intern("register"), 1, provider);

  // Use the provider to register a tracepoint
  SDTProbe_t *probe = provider_add_tracepoint_internal(cProviderInst, c_name_str, vargs);
  TypedData_Get_Struct(self, static_tracing_tracepoint_t, &static_tracing_tracepoint_type, tracepoint);

  // Stare the tracepoint handle in our struct
  tracepoint->sdt_tracepoint = probe;

  return self;
}

VALUE
tracepoint_fire(VALUE self, VALUE vargs)
{
  static_tracing_tracepoint_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_tracepoint_t, &static_tracing_tracepoint_type, res);
  probeFire(res->sdt_tracepoint); // FIXME vargs
  return Qnil;
}

VALUE
tracepoint_enabled(VALUE self)
{
  static_tracing_tracepoint_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_tracepoint_t, &static_tracing_tracepoint_type, res);
  int retval = probeIsEnabled(res->sdt_tracepoint);
  return INT2NUM(retval);
}

static const char*
check_name_arg(VALUE name)
{
  const char *c_name_str = NULL;

  if (TYPE(name) != T_SYMBOL && TYPE(name) != T_STRING) {
    rb_raise(rb_eTypeError, "name must be a symbol or string");
  }
  if (TYPE(name) == T_SYMBOL) {
    c_name_str = rb_id2name(rb_to_id(name));
  } else if (TYPE(name) == T_STRING) {
    c_name_str = RSTRING_PTR(name);
  }

  return c_name_str;
}

static const char*
check_provider_arg(VALUE provider)
{
  const char *c_provider_str = NULL;

  if (TYPE(provider) != T_SYMBOL && TYPE(provider) != T_STRING) {
    rb_raise(rb_eTypeError, "provider must be a symbol or string");
  }
  if (TYPE(provider) == T_SYMBOL) {
    c_provider_str = rb_id2name(rb_to_id(provider));
  } else if (TYPE(provider) == T_STRING) {
    c_provider_str = RSTRING_PTR(provider);
  }

  return c_provider_str;
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

static const rb_data_type_t
static_tracing_tracepoint_type = {
  "static_tracing_tracepoint",
  {
    static_tracing_tracepoint_mark,
    static_tracing_tracepoint_free,
    static_tracing_tracepoint_memsize
  },
  NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
};
