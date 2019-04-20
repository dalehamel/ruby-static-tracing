#include "ruby_static_tracing.h"

VALUE eUSDT, eInternal;

void Init_ruby_static_tracing() {
  VALUE cStaticTracing, cProvider, cTracepoint;

  cStaticTracing = rb_const_get(rb_cObject, rb_intern("StaticTracing"));

  /*
   * Document-class: StaticTracing::Provider
   *
   *  Provider is the wrapper around libstapsdt
   */
  cProvider = rb_const_get(cStaticTracing, rb_intern("Provider"));

  /*
   * Document-class: Statictracing::Tracepoint
   *
   *  A Tracepoint is a wrapper around an SDTProbe
   */
  cTracepoint = rb_const_get(cStaticTracing, rb_intern("Tracepoint"));

  /* Document-class: StaticTracing::SyscallError
   *
   * Represents failures to fire a tracepoint or register a provider
   */
  eUSDT = rb_const_get(cStaticTracing, rb_intern("USDTError"));

  /* Document-class: StaticTracing::InternalError
   *
   * An internal StaticTracing error. These errors may constitute bugs.
   */
  eInternal = rb_const_get(cStaticTracing, rb_intern("InternalError"));

  rb_define_alloc_func(cProvider, static_tracing_provider_alloc);
  rb_define_method(cProvider, "provider_initialize", provider_initialize, 1);
  rb_define_method(cProvider, "enable", provider_enable, 0);
  rb_define_method(cProvider, "disable", provider_disable, 0);
  rb_define_method(cProvider, "destroy", provider_destroy, 0);

  rb_define_alloc_func(cTracepoint, static_tracing_tracepoint_alloc);
  rb_define_method(cTracepoint, "tracepoint_initialize", tracepoint_initialize,
                   3);
  rb_define_method(cTracepoint, "_fire_tracepoint", tracepoint_fire, 1);
  rb_define_method(cTracepoint, "enabled?", tracepoint_enabled, 0);
}
