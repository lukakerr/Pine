
#ifndef CMARKEXTENSIONS_EXPORT_H
#define CMARKEXTENSIONS_EXPORT_H

#ifdef CMARKEXTENSIONS_STATIC_DEFINE
#  define CMARKEXTENSIONS_EXPORT
#  define CMARKEXTENSIONS_NO_EXPORT
#else
#  ifndef CMARKEXTENSIONS_EXPORT
#    ifdef libcmark_gfmextensions_EXPORTS
        /* We are building this library */
#      define CMARKEXTENSIONS_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define CMARKEXTENSIONS_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef CMARKEXTENSIONS_NO_EXPORT
#    define CMARKEXTENSIONS_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef CMARKEXTENSIONS_DEPRECATED
#  define CMARKEXTENSIONS_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef CMARKEXTENSIONS_DEPRECATED_EXPORT
#  define CMARKEXTENSIONS_DEPRECATED_EXPORT CMARKEXTENSIONS_EXPORT CMARKEXTENSIONS_DEPRECATED
#endif

#ifndef CMARKEXTENSIONS_DEPRECATED_NO_EXPORT
#  define CMARKEXTENSIONS_DEPRECATED_NO_EXPORT CMARKEXTENSIONS_NO_EXPORT CMARKEXTENSIONS_DEPRECATED
#endif

#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef CMARKEXTENSIONS_NO_DEPRECATED
#    define CMARKEXTENSIONS_NO_DEPRECATED
#  endif
#endif

#endif
