(module lang-type (lib "eopl.ss" "eopl")
  (provide (all-defined-out))
  (require "0-lang.scm")
  ;;============================================================== TEnv 
  (define-datatype TEnv TEnv?
    ($empty-tenv)
    ($extend-tenv
     (var symbol?)
     (ty Type?)
     (tenv TEnv?))
    ; module
    ($extend-tenv-with-module
     (name symbol?)
     (face SimpleInterface?)
     (tenv TEnv?))
    ; expanded-type
    ($extend-tenv-with-type
     (name Type?)  ; named type:  1 transparent Point = Int  2 type Point = Int    |    qualified type(opaque type) :  m1::Point
     (type Type?)  ;         m1::Point ~  Int                                      |           m1::Point ~ m1::Point
     (tenv TEnv?))
    )

  (define (get-nested-tenv tenv)
    (cases TEnv tenv
      ($empty-tenv ()
                   (eopl:error 'get-nested-tenv "No nested tenv for Empty-tenv !"))
      ($extend-tenv (saved-var saved-ty saved-tenv)
                    saved-tenv)
      ($extend-tenv-with-module (mod-name face saved-tenv)
                                saved-tenv)
      ($extend-tenv-with-type (ty etype saved-tenv)
                              saved-tenv)
      ))

  (define (init-tenv)
    ($extend-tenv 'i ($int-type)
                  ($extend-tenv 'v ($int-type)
                                ($extend-tenv 'x ($int-type) ($empty-tenv)))))
  
  (define (apply-tenv tenv var)
    (cases TEnv tenv
      ($empty-tenv ()
                   (eopl:error 'apply-tenv "Didn't find in type-env while search : ~s" var))
      ($extend-tenv (saved-var saved-ty saved-tenv)
                    (if (equal? var saved-var)
                        saved-ty
                        (apply-tenv saved-tenv var)))
      ($extend-tenv-with-module (mod-name face saved-tenv)
                                (apply-tenv saved-tenv var))
      ($extend-tenv-with-type (ty etype saved-tenv)
                              (apply-tenv saved-tenv var))

      ))
  ;----------------------------------------------------------- Observer: 在TEnv中查找module内的var的type
  ; lookup-module-name-in-tenv :: TEnv * Symbol -> ModuleInterface
  (define (lookup-module-in-tenv tenv m-name)
    (cases TEnv tenv
      ($extend-tenv-with-module (mod-id face saved-tenv)
                                (if (eqv? m-name mod-id)
                                    face
                                    (lookup-module-in-tenv saved-tenv m-name)))
      (else (lookup-module-in-tenv (get-nested-tenv tenv) m-name))))

  ; lookup-qualified-var-in-tenv :: Symbol * Symbol * TEnv -> Type                      
  (define (lookup-qualified-var-in-tenv m-name var-name tenv)
    (let ((iface (lookup-module-in-tenv tenv m-name)))
      (cases SimpleInterface iface
        ($a-simple-interface (decls)
                             (lookup-variable-name-in-decls var-name decls)))))

  ; lookup-variable-name-in-decls :: Symbol * [VarDeclaration] -> Type
  (define (lookup-variable-name-in-decls var-name decls)
    (cases VarDeclaration (car decls)
      ($a-var-declaration (var ty)
                          (if (eqv? var var-name)
                              ty
                              (lookup-variable-name-in-decls var-name (cdr decls))))
      (else (lookup-variable-name-in-decls var-name (cdr decls)))))  
  ; =============================================================================
  ;; type-to-external-form : Type -> List
  (define type-to-external-form
    (lambda (ty)
      (cases Type ty
        ($int-type ()
                   'int)
        ($bool-type ()
                    'bool)
        ($proc-type (arg-type result-type)
                    (list (type-to-external-form arg-type) '-> (type-to-external-form result-type)))
        ;
        ($named-type (t)
                     t)
        ($qualified-type (mod-name ty)
                         (string->symbol (string-append (symbol->string mod-name) "::"(symbol->string ty))))
        )))

  (define (decl->name decl)
    (cases VarDeclaration decl
      ($a-var-declaration (var ty)
                          var)
      (else #f)
      ))
  
  (define (decl->type decl)
    (cases VarDeclaration decl
      ($a-var-declaration (var ty)
                          ty)
      (else #f)))      
  )
