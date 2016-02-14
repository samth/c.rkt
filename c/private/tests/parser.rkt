#lang racket/base

(require rackunit
         "../../parse.rkt")

;; these aren't real tests... I just took the commented text below
;; and made sure that they either parsed successfully or didn't parse.

(define programs-to-parse
  (list
   "typedef enum { T = 128 } E; typedef int T[T]; T x;"
   "enum { A = 0, B = A + 1 } E;"
   "typedef int foo; struct s { int foo; };"
   "typedef int foo; struct foo { int x; };"
   "int (*(apfi[3]))(int x, int y);             // array of pointers to functions"
   "int *f(int x, int y);                       // function that returns int pointer"
   "int *(f)(int x, int y);                     // function that returns int pointer"
   "int (*f)(int x, int y);                     // pointer to function"
   "int i[2]={1,2};"
   "int i[2]=(int[]){1,2};"))

(define programs-with-errors
  (list
   "typedef int t; sizeof(int(int t, t x)); " #;"parse error"
   "typedef int t; sizeof(int(int t)); { t x; } " #;"formals scope restricted to formals"
   "typedef int T; ... { enum E { T = 128, U = T + 1 } }" #;"parse error"
   "typedef int t; ... { enum E { t = t }; }   " #;" // parse error"))


(for ([p programs-to-parse])
  (check-not-exn
   (lambda () (parse-program p))))

(for ([p programs-with-errors])
  (check-exn (lambda (exn) #t)
             (lambda () (parse-program p)) ""))


;; TESTS:
;;   - typedef enum { T = 128 } E; typedef int T[T]; T x;
;;   - enum { A = 0, B = A + 1 } E;
;;   - typedef int foo; struct s { int foo; };
;;   - typedef int foo; struct foo { int x; };
;;   - int (*(apfi[3]))(int x, int y);             // array of pointers to functions
;;   - int *f(int x, int y);                       // function that returns int pointer
;;   - int *(f)(int x, int y);                     // function that returns int pointer
;;   - int (*f)(int x, int y);                     // pointer to function
;;   - typedef int t; sizeof(int(int t, t x));     // parse error
;;   - typedef int t; sizeof(int(int t)); { t x; } // formals scope restricted to formals
;;   - typedef int T; ... { enum E { T = 128, U = T + 1 } }
;;   - typedef int t; ... { enum E { t = t }; }    // parse error
