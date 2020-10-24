;Programme en assembleur 8086 qui permet de convertir un nombre DCB de 8 bits en hexadecimal
                                                                     
.MODEL SMALL

.STACK 100H

.DATA
    msg1 DB 'Ceci est un programme qui permet de convertir un nombre DCB de 8 bits en hexadecimal$'
    msg2 DB "Veuiller entrer votre nombre s'il vous plait:$"
    msg3 DB 'Votre nombre de 8 bits en hexadecimal est: $'
    msg4 DB 'Votre nombre est sur 8 bits donc il droit etre compris entre 0 et 255$'
    ma DB 'A$'
    mb DB 'B$'
    mc DB 'C$'
    md DB 'D$'
    me DB 'E$'
    mf DB 'F$'
    
    affichmsg macro msg
          PUSH AX
          PUSH DX
          LEA DX, msg
          MOV AH, 09H
          INT 21H
          POP DX
          POP AX
    ENDM
    
    newline MACRO
        PUSH AX
        MOV AL, 0AH
        MOV AH, 0EH
        INT 10H
     
        MOV AL, 0DH
        MOV AH, 0EH
        INT 10H
        POP AX
    ENDM
    
    PUTC    macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
    ENDM
    
.CODE
    MOV AX, @DATA ;Initialise le segment des donnees
    MOV DS, AX
    
    affichmsg msg1 ;Affiche un message qui decrit le programme
    newline        ;va a la ligne
    affichmsg msg2 ;affiche un message qui demande le nombre
    call SCAN_NUM  ;lit le nombre a partir du clavier
    newline        
    MOV AX,CX      ;ON place le nombre en AX pour pouvoir effectuer la division
    CMP AX,255     ;On compare le nombre avec 255
    JA erreur      ;Si le nombre est plus grand que 255, on depasse la barre de 8 bits
                   ;un message d'erreur apparait et termine le programme
                   
    MOV BX,16      ;on met 16 dans bx pour la division et la conversion en hexadecimal
    DIV BX         ;on divise par 16
    
    MOV CL,DL
    MOV DL,AL
    
    CMP DL,9      ;on verifie si le nombre est plus grand que 9
    JA call lettres_dl1 ;si c'est le cas, on affiche la lettre hexadecimale correspondante
    ;on affiche le premier chiffre
    ADD DL,48          
    MOV AH,02H
    INT 21H
    
    ;on repete le processus pour le second chiffre
    ;comme on a un nombre de 8 bits, on aura seulement 2 caracteres hexadecimaux
    chiffre2:
    MOV DL,CL
    
    CMP DL,9
    JA call lettres_dl2
    ADD DL,48
    MOV AH,02H
    INT 21H
    newline
    JMP exit
    
    exit:
        MOV AH,4CH
        INT 21H   
     
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
    
    erreur:
        affichmsg msg4
        JMP exit 
    
     lettres_dl1:
        CMP DL,10
        JE la
        CMP DL,11
        JE lb 
        CMP DL,12
        JE lc 
        CMP DL,13             
        JE ld 
        CMP DL,14
        JE le 
        CMP DL,15
        JE lf
        
     la:
        affichmsg ma
        JMP chiffre2
     lb:
        affichmsg mb
        JMP chiffre2
     lc:
        affichmsg mc
        JMP chiffre2
     ld:
        affichmsg md
        JMP chiffre2
     le:
        affichmsg me
        JMP chiffre2
     lf:
        affichmsg mf
        JMP chiffre2
        
      lettres_dl2:
        CMP DL,10
        JE la1
        CMP DL,11
        JE lb1 
        CMP DL,12
        JE lc1 
        CMP DL,13             
        JE ld1 
        CMP DL,14
        JE le1 
        CMP DL,15
        JE lf1
        
     la1:
        affichmsg ma
        JMP exit
     lb1:
        affichmsg mb
        JMP exit
     lc1:
        affichmsg mc
        JMP exit
     ld1:
        affichmsg md
        JMP exit
     le1:
        affichmsg me
        JMP exit
     lf1:
        affichmsg mf
        JMP exit 