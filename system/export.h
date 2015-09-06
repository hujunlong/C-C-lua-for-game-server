#pragma once

/*  Handle DSO symbol visibility                                             */
#if defined _WIN32
#   if defined DLL_EXPORT
#       define FUNCTION_EXPORT __declspec(dllexport)
#   else
#       define FUNCTION_EXPORT __declspec(dllimport)
#   endif
#else
#   if defined __SUNPRO_C  || defined __SUNPRO_CC
#       define FUNCTION_EXPORT __global
#   elif (defined __GNUC__ && __GNUC__ >= 4) || defined __INTEL_COMPILER
#       define FUNCTION_EXPORT __attribute__ ((visibility("default")))
#   else
#       define FUNCTION_EXPORT
#   endif
#endif