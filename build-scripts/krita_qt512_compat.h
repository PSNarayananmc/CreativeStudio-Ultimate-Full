// krita_qt512_compat.h — Qt 5.12.8 compatibility shim for Krita 5.2.16
//
// Forced-included on every translation unit (see build-scripts/
// 04-configure-krita.sh: -include krita_qt512_compat.h) so that engine
// code written against newer Qt headers compiles unmodified on focal's
// Qt 5.12.8. Engine code itself is unchanged (documented in
// compliance/SOURCE-CODE-OFFER.txt as modification 1).
//
// Provides:
//   * Q_DISABLE_COPY_MOVE — introduced in Qt 5.13, used by Krita 5.2 code
//   * <memory>/<vector>/<string>/<QVector> — newer Qt public headers rely
//     on these transitively; 5.12 does not always pull them in
//
// Qt headers are guarded with __has_include because CMake's compiler
// sanity-check compiles this file WITHOUT Qt include paths.
#ifndef KRITA_QT512_COMPAT_H
#define KRITA_QT512_COMPAT_H

#include <memory>
#include <vector>
#include <string>

#if defined(__has_include)
#  if __has_include(<QtGlobal>)
#    include <QtGlobal>
#  endif
#  if __has_include(<QVector>)
#    include <QVector>
#  endif
#endif

// Macro bodies expand at use-site, so Q_DISABLE_COPY only needs to be
// defined when Q_DISABLE_COPY_MOVE is actually used (i.e. in Qt TUs).
#ifndef Q_DISABLE_COPY_MOVE
#define Q_DISABLE_COPY_MOVE(Class) \
    Q_DISABLE_COPY(Class)          \
    Class(Class &&) = delete;      \
    Class &operator=(Class &&) = delete;
#endif

#endif // KRITA_QT512_COMPAT_H
