#include "tracepoint.h"

static const rb_data_type_t static_tracing_tracepoint_type;

static const char *check_name_arg(VALUE provider);

static const char *check_provider_arg(VALUE provider);

static char **check_vargs(int *argc, VALUE vargs);

static void **check_fire_args(int *argc, VALUE vargs);

VALUE
tracepoint_initialize(VALUE self, VALUE provider, VALUE name, VALUE vargs) {
  VALUE cStaticTracing, cProvider, cProviderInst;
  static_tracing_tracepoint_t *tracepoint = NULL;
  const char *c_name_str = NULL;
  int argc = 0;

  c_name_str = check_name_arg(name);
  check_provider_arg(provider); // FIXME should only accept string
  char **args = check_vargs(&argc, vargs);

  /// Get a handle to global provider list for lookup
  cStaticTracing = rb_const_get(rb_cObject, rb_intern("StaticTracing"));
  cProvider = rb_const_get(cStaticTracing, rb_intern("Provider"));
  cProviderInst = rb_funcall(cProvider, rb_intern("register"), 1, provider);

  // Create a probe
  usdt_probedef_t *probe =
      usdt_create_probe(c_name_str, c_name_str, argc, args);

  // Use the provider to register a tracepoint
  int success = provider_add_tracepoint_internal(
      cProviderInst, probe); // FIXME handle error checking here and throw an
                             // exception if failure
  TypedData_Get_Struct(self, static_tracing_tracepoint_t,
                       &static_tracing_tracepoint_type, tracepoint);

  // FIXME check for nulls
  // FIXME Do we really need to store both references? refactor this.
  // Store the tracepoint handle in our struct
  tracepoint->usdt_tracepoint_def = probe;

  return self;
}

VALUE
tracepoint_fire(VALUE self, VALUE vargs) {
  static_tracing_tracepoint_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_tracepoint_t,
                       &static_tracing_tracepoint_type, res);
  int argc = 0;
  void *args = check_fire_args(&argc, vargs);

  usdt_fire_probe(res->usdt_tracepoint_def->probe, argc, args);
  return Qnil;
}

VALUE
tracepoint_enabled(VALUE self) {
  static_tracing_tracepoint_t *res = NULL;
  TypedData_Get_Struct(self, static_tracing_tracepoint_t,
                       &static_tracing_tracepoint_type, res);
  return usdt_is_enabled(res->usdt_tracepoint_def->probe) == 0 ? Qfalse : Qtrue;
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

static const char *check_provider_arg(VALUE provider) {
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

static char **check_vargs(int *argc, VALUE vargs) {
  if (TYPE(vargs) == T_ARRAY) {
    VALUE rLength = rb_funcall(vargs, rb_intern("length"), 0, Qnil);
    *argc = NUM2INT(rLength);

    if (*argc > 6) {
      printf("ERROR - passed %i args, maximum 6 argument types can be passed",
             *argc);
      return NULL;
    }
    // FIXME ensure this is freed
    char **args = malloc(*argc * sizeof(char *));
    for (int i = 0; i < *argc; i++) {
      VALUE str =
          rb_funcall(rb_ary_entry(vargs, i), rb_intern("to_s"), 0, Qnil);
      const char *cStr = RSTRING_PTR(str);
      if (strcmp(cStr, "Integer")) {
        args[i] = strdup(cStr);
      } else if (strcmp(cStr, "String")) {
        args[i] = strdup(cStr);
      } else {
        printf("ERROR - type \"%s\" is unsupported\n", cStr);
      }
    }
    return args;
  } else {
    printf("ERROR - array was expected\n");
    return NULL;
  }
}

/*
 * Yeah, returning a void ** array is a bit sketchy, but since
 * usdt_fire_probe takes a void **, that's what we'll give it.
 *
 * The structure of the data is actually an array of 64 bit unions
 * So the size of the data should be argc * 8 bytes.
 * We assume that reads will be aligned on 64 bits in the tracer.
 *
 * The approach libstapsdt takes is pretty similar, just not an array.
 */
static void **check_fire_args(int *argc, VALUE vargs) {
  if (TYPE(vargs) == T_ARRAY) {
    VALUE rLength = rb_funcall(vargs, rb_intern("length"), 0, Qnil);
    *argc = NUM2INT(rLength);

    if (*argc > 6) {
      printf("ERROR - passed %i args, maximum 6 argument types can be passed",
             *argc);
      return NULL;
    }

    Tracepoint_fire_arg *args = malloc(*argc * sizeof(Tracepoint_fire_arg));
    // printf("SIZE: %i ARGC: %i \n", sizeof(Tracepoint_fire_arg), *argc);
    // FIXME check against registered argtypes here
    for (int i = 0; i < *argc; i++) {
      VALUE val = rb_ary_entry(vargs, i);
      switch (TYPE(val)) {
      case T_FIXNUM:
        args[i].intval = FIX2LONG(val);
        break;
      case T_STRING:
        args[i].strval = RSTRING_PTR(val);
        break;
      default:
        printf("ERROR unsupported type passed for argument %i to fire\n", i);
        break;
      }
    }
    // This downcast is explained the comment section of this function.
    return (void **)args;
  } else {
    printf("ERROR - array was expected\n");
    return NULL;
  }
}

// Allocate a static_tracing_tracepoint_type struct for ruby memory management
VALUE
static_tracing_tracepoint_alloc(VALUE klass) {
  static_tracing_tracepoint_t *res;
  VALUE obj = TypedData_Make_Struct(klass, static_tracing_tracepoint_t,
                                    &static_tracing_tracepoint_type, res);
  return obj;
}

static inline void static_tracing_tracepoint_mark(void *ptr) { /* noop */
}

static inline void static_tracing_tracepoint_free(void *ptr) {
  static_tracing_tracepoint_t *res = (static_tracing_tracepoint_t *)ptr;
  // if (res->name) {
  //  free(res->name);
  //  res->name = NULL;
  //}
  xfree(res);
}

static inline size_t static_tracing_tracepoint_memsize(const void *ptr) {
  return sizeof(static_tracing_provider_t);
}

static const rb_data_type_t static_tracing_tracepoint_type = {
    "static_tracing_tracepoint",
    {static_tracing_tracepoint_mark, static_tracing_tracepoint_free,
     static_tracing_tracepoint_memsize},
    NULL,
    NULL,
    RUBY_TYPED_FREE_IMMEDIATELY};
