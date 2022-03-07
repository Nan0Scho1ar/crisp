(begin
  (define a 10)
  (define b 20)
  (define double-then-add
    (lambda (x y)
      (+ ((lambda (i) (+ i i)) x)
         ((lambda (j) (begin
                   (print a)
                   (+ j j))) y))))
  (double-then-add a b))
