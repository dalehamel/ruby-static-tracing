#include "provider.h"

#include <string.h>

static const rb_data_type_t static_tracing_provider_type;

// Forward decls
static const char *check_name_arg(VALUE name);

/*
  Wraps ProviderInit from libstapsdt
*/
VALUE
provider_initialize(VALUE self, VALUE name) {
  const char *c_name_str = NULL;
  static_tracing_provider_t *res = NULL;

  // Check and cast arguments
  c_name_str = check_name_arg(name);

  // Build provider structure
  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);
  res->sdt_provider = providerInit(c_name_str);
  return self;
}

// Internal function used to register a tracepoint against a provider instance
SDTProbe_t *provider_add_tracepoint_internal(VALUE self, const char *name,
                                             int argc,
                                             Tracepoint_arg_types *args) {
  static_tracing_provider_t *res = NULL;
  SDTProbe_t *probe;

  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);

  switch (argc) {
  case 0:
    probe = providerAddProbe(res->sdt_provider, name, 0);
    break;
  case 1:
    probe = providerAddProbe(res->sdt_provider, name, argc, args[0]);
    break;
  case 2:
    probe = providerAddProbe(res->sdt_provider, name, argc, args[0], args[1]);
    break;
  case 3:
    probe = providerAddProbe(res->sdt_provider, name, argc, args[0], args[1],
                             args[2]);
    break;
  case 4:
    probe = providerAddProbe(res->sdt_provider, name, argc, args[0], args[1],
                             args[2], args[3]);
    break;
  case 5:
    probe = providerAddProbe(res->sdt_provider, name, argc, args[0], args[1],
                             args[2], args[3], args[4]);
    break;
  case 6:
    probe = providerAddProbe(res->sdt_provider, name, argc, args[0], args[1],
                             args[2], args[3], args[4], args[5]);
    break;
  default:
    probe = providerAddProbe(res->sdt_provider, name, 0);
    break;
  }

  return probe;
}

/*
  Wraps providerLoad from libstapsdt
*/
VALUE
provider_enable(VALUE self) {
  static_tracing_provider_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);
  return providerLoad(res->sdt_provider) == 0 ? Qtrue : Qfalse;
}

/*
  Wraps providerUnload from libstapsdt
*/
VALUE
provider_disable(VALUE self) {
  static_tracing_provider_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);
  res->sdt_provider->_filename = NULL; // FIXME upstream should do this
  return providerUnload(res->sdt_provider) == 0 ? Qtrue : Qfalse;
}

/*
  Wraps providerDestroy from libstapsdt
*/
VALUE
provider_destroy(VALUE self) {
  static_tracing_provider_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);
  providerDestroy(res->sdt_provider);
  return Qnil;
}

VALUE
provider_path(VALUE self) {
  VALUE path;
  char *_path;
  static_tracing_provider_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_provider_t,
                       &static_tracing_provider_type, res);

  if (res != NULL && res->sdt_provider != NULL &&
      res->sdt_provider->_filename != NULL) {
    _path = res->sdt_provider->_filename;
    path = strlen(_path) > 0 ? rb_str_new_cstr(_path) : rb_str_new_cstr("");
  } else {
    path = rb_str_new_cstr("");
  }
  return path;
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
