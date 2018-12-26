(module lang (lib "eopl.ss" "eopl")
  (provide (all-defined-out))
  
  (define the-lexical-spec
    '((whitespace (whitespace) skip)      
      (comment ("%" (arbno (not #\newline)))skip)
      (identifier (letter (arbno (or letter digit "_" "-" "?"))) symbol)
      (number (digit (arbno digit)) number)
      (number ("-" digit (arbno digit)) number)
      ))

  (define the-grammar
    '(
      ;; 【Program】
      (program (expression) a-program)
      ;; 【Expression】      
      ; const-exp , zero? , diff-exp ,  if-exp , var-exp, let-exp
      (expression (number) const-exp)
      (expression (identifier) var-exp)
      (expression ("-" "(" expression "," expression ")")  diff-exp)
      (expression ("zero?" "(" expression ")") zero?-exp)
      (expression ("if" expression "then" expression "else" expression)  if-exp)
      (expression ("let" identifier "=" expression "in" expression) let-exp)
      
      ; ★ operators
      (expression ("+" "(" expression "," expression ")") add-exp)
      (expression ("*" "(" expression "," expression ")") mult-exp)
      ; //TODO   lets , letrec
      ; //TODO   cons,car,cdr,emptylist, list
      ; //TODO   cond
      ; //TODO   print
      ; //TODO   > < ==
      
      ; ★ proc
      ; 0/multi-arguments procedure support
      (expression ("proc" "(" (arbno identifier) ")" expression) proc-exp)
      (expression ("(" expression (arbno expression) ")") call-exp)
      ; letrec  // letrec double(x) = ... in 
      (expression ("letrec" identifier "(" identifier ")" "=" expression "in" expression) letrec-exp)
      ))
      
  ;;================================================================== SLLGEN
  (sllgen:make-define-datatypes the-lexical-spec the-grammar)  
  (define show-the-datatypes
    (lambda () (sllgen:list-define-datatypes the-lexical-spec the-grammar)))
  (define just-scan
    (sllgen:make-string-scanner the-lexical-spec the-grammar))  
  (define scan&parse
    (sllgen:make-string-parser the-lexical-spec the-grammar)) 
  
  )