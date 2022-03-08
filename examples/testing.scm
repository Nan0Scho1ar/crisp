(begin
  (define a 10)
  (define b 20)
  (define double-then-add
    (lambda (x y)
      (+ ((lambda (i) (* i 2)) x)
         ((lambda (j) (* j 2)) y))))
  (double-then-add a b))
