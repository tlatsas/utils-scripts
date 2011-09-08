#! /bin/sh

# format xprop output for xmonad use
# source: http://www.haskell.org/haskellwiki/Xmonad/Frequently_asked_questions

exec xprop -notype \
  -f WM_NAME        8s ':\n       title =\? $0\n  [IM] Title $0\n\n' \
  -f WM_CLASS       8s ':\n       appName =\? $0\n  [IM] Resource $0\n       className =\? $1\n  [IM] ClassName $1\n\n' \
  -f WM_WINDOW_ROLE 8s ':\n       stringProperty "WM_WINDOW_ROLE" =\? $0\n' \
  WM_NAME WM_CLASS WM_WINDOW_ROLE \
  ${1+"$@"}
