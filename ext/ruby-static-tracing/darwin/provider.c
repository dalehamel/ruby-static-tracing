#include "provider.h"

static const rb_data_type_t static_tracing_provider_type;

// Forward decls
static const char *check_name_arg(VALUE name);

/*
  Wraps usdt_create_provider from libusdt.h
*/
VALUE
provider_initialize(VALUE self, VALUE name) {
  const char *c_name_str = NULL;
  static_tracing_provider_t *res = NULL;

  c_name_str = check_name_arg(name);

  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);
  res->usdt_provider = usdt_create_provider(
      c_name_str,
      c_name_str); // FIXME make module from name and just prepend "_module_"
  return self;
}

// // Internal function used to register a tracepoint against a provider
// instance
int provider_add_tracepoint_internal(VALUE self, usdt_probedef_t *probedef) {
  static_tracing_provider_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);
  return usdt_provider_add_probe(res->usdt_provider, probedef) == 0 ? Qtrue
                                                                    : Qfalse;
}

/*
  Wraps usdt_provider_enable from libusdt.h
*/
VALUE
provider_enable(VALUE self) {
  static_tracing_provider_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);
  return usdt_provider_enable(res->usdt_provider) == 0 ? Qtrue : Qfalse;
}

/*
 Wraps usdt_provider_disable from libusdt.h
*/
VALUE
provider_disable(VALUE self) {
  static_tracing_provider_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);
  return usdt_provider_disable(res->usdt_provider) == 0 ? Qtrue : Qfalse;
}

/*
 Wraps usdt_provider_free from libusdt.h
*/
VALUE
provider_destroy(VALUE self) {
  static_tracing_provider_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);
  usdt_provider_free(res->usdt_provider);
  return Qnil;
}

// Allocate a static_tracing_provider_type struct for ruby memory management
VALUE
static_tracing_provider_alloc(VALUE klass) {
  static_tracing_provider_t *res;
  VALUE obj = TypedData_Make_Struct(klass, static_tracing_provider_t,
                                    &static_tracing_provider_type, res);
  return obj;
}

static const char *check_name_arg(VALUE name) {
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

static inline void static_tracing_provider_mark(void *ptr) { /* noop */
}

static inline void static_tracing_provider_free(void *ptr) {
  static_tracing_provider_t *res = (static_tracing_provider_t *)ptr;
  // if (res->name) {
  //  free(res->name);
  //  res->name = NULL;
  //}
  xfree(res);
}

static inline size_t static_tracing_provider_memsize(const void *ptr) {
  return sizeof(static_tracing_provider_t);
}

static const rb_data_type_t static_tracing_provider_type = {
    "static_tracing_provider",
    {static_tracing_provider_mark, static_tracing_provider_free,
     static_tracing_provider_memsize},
    NULL,
    NULL,
    RUBY_TYPED_FREE_IMMEDIATELY};
