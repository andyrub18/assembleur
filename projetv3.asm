;Un programme ecrit en assembleur 8086 qui calcule le pgcd de deux nombres a partir de l'algorithme d'Euclide
;et le ppmc de ces deux nombres

.MODEL SMALL

.STACK 100H

.DATA
    d1 dw ?
    d2 dw ?
    d3 dw ?
    msg1 db 'Ce programme calcule le PGCD de deux nombres de 0 a 65535$'
    msg2 db 'Entrez le premier nombre:$'
    msg3 db 'Entrez le second nombre:$'
    msg4 db 'Le PGCD est:$'
    msg5 db 'Le PPMC est:$'
    
    PUTC MACRO CHAR
        PUSH AX
        MOV AL, CHAR
        MOV AH, 0EH
        INT 10H
        POP AX
    ENDM
    
    NEWLINE MACRO
        PUSH AX
        MOV AL, 0AH
        MOV AH, 0EH
        INT 10H
     
        MOV AL, 0DH
        MOV AH, 0EH
        INT 10H
        POP AX
    ENDM
    
.CODE
    MAIN PROC FAR
        MOV AX,@DATA
        MOV DS,AX
        
        ;ON AFFICHE UN MESSAGE QUI DECRIT LE PROGRAMME
        PUSH AX
        LEA DX, msg1
        MOV AH, 09H
        INT 21H
        POP AX
        
        ;ON VA A LA LIGNE
        NEWLINE
        
        ;ON DEMANDE LE PREMIER NOMBRE A L'UTILISATEUR
        PUSH AX
        LEA DX, msg2
        MOV AH, 09H
        INT 21H
        POP AX
        
        ;ON LIT LE PREMIER NOMBRE QUE L'UTILISATEUR ENTRE SUR LE CLAVIER ET ON LE MET DANS d2
        call SCAN_NUM
        MOV d2,CX
        
        ;ON VA A LA LIGNE
        NEWLINE
        
        ;ON DEMANDE LE SECOND NOMBRE A L'UTILISATEUR
        PUSH AX
        LEA DX, msg2
        MOV AH, 09H
        INT 21H
        POP AX
        
        ;ON LIT LE SECOND NOMBRE QUE L'UTILISATEUR ENTRE SUR LE CLAVIER ET ON LE MET DANS D1
        call SCAN_NUM
        MOV d1,CX
        
        ;ON VA A LA LIGNE
        NEWLINE
        
        ;INTIALISE AX ET BX
        MOV BX,d2
        MOV AX,d1
        
        ;ON APPELLE LA PROCEDURE QUI CALCULE LE PGCD
        call GCD
        
        ;ON MET LE GCD DANS AX
        MOV AX,CX
        MOV d3,AX
        
        ;AFFICHE LA VALEUR DU PGCD
        PUSH AX
        LEA DX, msg4
        MOV AH, 09H
        INT 21H
        POP AX
        call PRINT
        
        ;ON VA A LA LIGNE
        NEWLINE
        
        ;ON APPELLE LA PROCEDURE QUI CALCULE LE PPMC
        call PPMC
        
        ;AFFICHE LA VALEUR DU PPMC
        PUSH AX
        LEA DX, msg5
        MOV AH, 09H
        INT 21H
        POP AX
        call PRINT
         
        ;ON VA A LA LIGNE
        NEWLINE
        
        ;TERMINE LE PROGRAMME
        MOV AH,4CH
        INT 21H
        
        MAIN ENDP
    
    GCD PROC
        CMP BX,0 ;ON COMPARE BX A 0
        JNE continue ;SI BX EST DIFFERENT DE 0, ON VA A LA PARTIE CONTINUE
        
        MOV CX,AX ;DANS LE CAS CONTRAIRE, LE PGCD EST AX
        RET ;ON RETOURNE DANS LE PROGRAMME PRINCIPAL
        
        continue: ;SINON PGCD(B, A%B)
                XOR DX,DX ;CLEAR DX
                
                ;DIVISE AX BY BX
                DIV BX
                
                ;INITIALISE AX AVEC BX
                MOV AX,BX
                
                ;ET ON MET LA VALEUR DE AX % BX DANS BX
                MOV BX,DX
                
                ;ON APPELLE GCD DE MANIERE RECURSIVE
                call GCD
                ret ;POUR RETOURNER AU PROGRAMME
                GCD ENDP
    
    PPMC PROC
        ;ON VA CALCULER LE PPMC GRACE AU PGCD AVEC LA FORMULE A*B=PPMC(A,B)*PGCD(A,B)
        ;LE PPMC PEUT ETRE DONC OBTENU DE LA MANIERE SUIVANTE:
        ;PPMC(A,B) = (A*B)/PGCD(A,B)
        
        ;ON MET DX A 0 POUR L'UTILISER POUR LA MULTIPLICATION
        XOR DX,DX
        
        ;ON MET LE PREMIER NOMBRE DANS AX 
        MOV AX,d1
        
        ;ON MET LE SECOND NOMBRE DANS BX 
        MOV BX,d2
        
        ;ON MULTIPLIE AX ET BX 
        MUL BX
        
        ;ON MET LE PGCD DANS BX 
        MOV BX,d3
        
        ;ON DIVISE LE PRODUIT DE A ET B PAR PGCD(A,B) 
        DIV BX
         
        ret ;POUR RETOURNER AU PROGRAMME
        PPMC ENDP
    
    PRINT PROC
        ;INITIALISER UN COMPTEUR
        MOV CX,0
        MOV DX,0
        
        label1:
            CMP AX,0 ;SI AX EST EGAL A 0
            JE print1
            
            ;INITIALISE BX A 10
            MOV BX,10
            
            ;ON EXTRAIT LE DERNIER CHIFFRE
            DIV BX
            
            ;ON LE MET DANS LE STACK
            PUSH DX
            
            ;ON INCREMENTE LE COMPTEUR
            INC CX
            
            ;ON MET DX A 0
            XOR DX,DX
            
            ;ON EXECUTE LABEL1 RECURSIVEMENT
            JMP label1
        
        print1:
            ;ON VERIFIE SI LE COMPTEUR EST PLUS GRAND QUE 0
            CMP CX,0
            JE exit
            
            ;ON EXTRAIT LES NOMBRE DANS LA PILE
            POP DX
            
            ;ON AJOUTE 48 POUR REPRESENTER LA VALEUR DANS LE TABLEAU ASCII
            ADD DX,48
            
            ;INTERRUPTION POUR AFFICHER UN CARACTERE
            MOV AH,02H
            INT 21H
            
            ;DECREMENTE LE COMPTEUR
            DEC CX
            JMP PRINT1
            
        exit: ret
        PRINT ENDP
    
    SCAN_NUM PROC NEAR
        PUSH DX
        PUSH AX
        PUSH SI
        
        MOV CX,0
        
        ;RESET FLAG:
        MOV CS:make_minus,0
        
        next_digit:
            ;LIT UN CARACTERE A PARTIR DU CLAVIER:
            MOV AH,00h
            INT 16H 
            
            ;ET L'IMPRIME:
            MOV AH,0EH
            INT 10H
            
            ;VERIFIER POUR NOMBRE NEGATIF:
            CMP AL,'-'
            JE set_minus
            
            ;VERIFIER SI L'UTILISATEUR APPUIE SUR LA TOUCHE 'ENTER':
            CMP AL,0DH ;CARRIAGE RETURN?
            JNE not_cr
            JMP stop_input
         
         not_cr:
            CMP AL,8  ;SI ON APPUIE SUR LA TOUCHE BACKSPACE
            JNE backspace_checked
            MOV DX,0  ;ENLEVER LE DERNIER NOMBRE
            MOV AX,CX ;METTRE CX DANS AX POUR EFFECTUER UNE DIVISION
            DIV CS:ten ; AX = DX:AX/10 (DX-REM)
            MOV CX,AX
            PUTC ' '   ;ENLEVE LE CARACTERE DE L'ESPACE
            PUTC 8     ;BACKSPACE ENCORE UNE FOIS
            JMP next_digit
            
         backspace_checked:
            ;ON ACCEPTE QUE LES CHIFFRES
            CMP AL,'0'
            JAE ok_AE_0
            JMP remove_not_digit
            
         ok_AE_0:
            CMP AL,'9'
            JBE ok_digit
         
         remove_not_digit:
            PUTC 8     ;BACKSPACE
            PUTC ' '   ;ENLEVE LE CARACTERE DE L'ESPACE
            PUTC 8     ;BACKSPACE ENCORE UNE FOIS
            JMP next_digit ;ON ATTEND QUE L'UTILISATEUR ENTRE UN AUTRE CARACTERE
            
         ok_digit:
            ;ON MULTIPLIE CX PAR 10 (LA PREMIERE FOIS, LE RESULTAT EST ZERO)
            PUSH AX
            MOV AX,CX
            MUL CS:ten  ;DX:AX = AX*10
            MOV CX,AX
            POP AX
            
            ;ON VERIFIE SI LE NOMBRE N'EST PAS TROP GRAND POUR EVITER LES OVERFLOW
            ;CAR LE RESULTAT DEVRAIT ETRE SUR 16 BITS 
            CMP DX,0
            JNE too_big
            
            ;ON CONVERTIT LE CARACTERE DE LA TABLE ASCII EN NOMBRE UTILISABLE POUR LES CALCULS
            SUB AL,30H
            
            ;ON AJOUTE AL A CX:
            MOV AH,0
            MOV DX,CX   ;ON SAUVEGARDE LE RESULTAT DANS LE CAS IL EST TROP GRAND
            ADD CX,AX
            JC  too_big2
            
            JMP next_digit
            
         set_minus:
            MOV CS:make_minus,1
            JMP next_digit
            
         too_big2:
            MOV CX,DX     ;RECUPERE LA VALEUR QU'ON AVAIT SAUVEGARDE AVANT LE ADD
            MOV DX,0      ;ON MET DX A 0 (SA VALEUR AVANT LA SAUVEGARDE)
             
         too_big:
            MOV AX,CX
            DIV CS:ten ;INVERSE LE DERNIER DX:AX=AX*10 EN FAISANT AX=DX:AX/10
            MOV CX,AX
            PUTC 8     ;BACKSPACE
            PUTC ' '   ;ENLEVE LE DERNIER CARACTERE ENTRE
            PUTC 8     ;BACKSPACE ENCORE UNE FOIS
            JMP next_digit ;ON ATTEND L'ENTREE D'UN AUTRE CARACTERE
            
         stop_input:
            ;CHECK FLAG:
            CMP CS:make_minus,0
            JE not_minus
            NEG CX
         
         not_minus:
            POP SI
            POP AX
            POP DX
            
            RET
         make_minus db ?  ;UTILISE COMME FLAG
         SCAN_NUM ENDP
    ten dw 10 ; UTILISE COMME MULTIPLICATEUR/DIVISEUR PAR LA PROCEDURE SCAN_NUM  
    END MAIN