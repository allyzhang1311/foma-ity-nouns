# Ally Zhang
# CS 4744
# HW2 - Question 5 - ITY Nouns

# Source files and FSTs
load defined ANV.fsb
load defined cmu2.fsb
define ToUppercase [[a:"A"] | [b:"B"] | [c:"C"] | [d:"D"] | [e:"E"] | [f:"F"] | [g:"G"] | [h:"H"] | [i:"I"] | [j:"J"] | [k:"K"] | [l:"L"] | [m:"M"] | [n:"N"] | [o:"O"] | [p:"P"] | [q:"Q"] | [r:"R"] | [s:"S"] | [t:"T"] | [u:"U"] | [v:"V"] | [w:"W"] | [x:"X"] | [y:"Y"] | [z:"Z"]]+;


## 5a.
# Defines a large set of orthographic adjectives that map to nouns ending in -ity.
define Ity1 [N /// {ity}] & A;
define Ity2 [[N /// {ity}] e] & A;
define Ity3 [[N /// {ity}] {ite}] & A;
define Ity4 [[N /// {ility}] {le}] & A;
define Ity5 [[N /// {ity}] {y}] & A;
define Ity6 [[N /// {ity}] {ous}] & A;
define Ity7 [[N /// {ity}] {al}] & A;
define Ity8 [[N /// {osity}] {ous}] & A;
define AllIty [[Ity1 | Ity2 | Ity3 | Ity4 | Ity5 | Ity6 | Ity7 | Ity8] .o. ToUppercase].l;

## 5b.
# The set containing all -ity adjectives that end in -al, -er, or -an.
define ItyAL AllIty & [?* {AL}|{ER}|{AN}];

# The set containing all -ity adjectives that end in -ile, -il, -able, or -ible.
define ItyILE AllIty & [?* [{ILE}|{IL}|{ABLE}|{IBLE}]];

# The set containing all -ity adjectives that end in -ous AND whose noun form ends in -osity.(Not the same as adjectives whose noun form ends only in -ity, like ENORMITY.)
define ItyOS AllIty & [Ity8 .o. ToUppercase].l;

# The set containing all other -ity adjectives.
define ItyREST AllIty - ItyAL - ItyILE - ItyOS;

# Maps the -ity adjectives into phonetic form.
define CMUItyAL ItyAL .o. CMU;
define CMUItyILE ItyILE .o. CMU;
define CMUItyOS ItyOS .o. CMU;
define CMUItyREST ItyREST .o. CMU;

# Adds the phonetic form of -ity in final context. 
define AddIty [[..] -> {AH0TIY0} || _ .#.];

#define UFormMakerAL _lm([CMUItyAL | "+":0 | {ITY}:{AH0TIY0}]);
#define UFormMakerILE _lm([CMUItyILE | "+":0 | {ITY}:{AH0TIY0}]+);
#define UFormMakerOS _lm([CMUItyOS | "+":0 | {ITY}:{AH0TIY0}]+);
#define UFormMakerREST _lm([CMUItyREST | "+":0 | {ITY}:{AH0TIY0}]+);

# Underlying phonetic forms of -ity nouns, converted into a letter machine.
define UFormAL AllIty .o. _lm(CMUItyAL) .o. AddIty;
define UFormILE AllIty .o. _lm(CMUItyILE) .o. AddIty;
define UFormOS AllIty .o. _lm(CMUItyOS) .o. AddIty;
define UFormREST AllIty .o. _lm(CMUItyREST) .o. AddIty;

## PHONOLOGY
# Deletes -ous when immediately followed by -ity. 
define OUSDeletion [{AH0S} -> 0 || _ {AH0TIY0}.#.];

# Destresses all vowels. (Not a real phonological rule; this is just for programming convenience)
define VowelDestress ["1" -> "0"];

# Stresses final pre-ity vowel of words ending in -al, -er, or -an.
define ALFinalVowelStress [{AH0L} -> {AE1L}, {ER0} -> {EH1R}, {AH0N} -> {AE1N} || _ {AH0TIY0}];

# Stresses final pre-ity vowel of words ending in -ile, -il, -able, or -ible.
define ILEFinalVowelStress [{AH0} -> {IH1} || _ {LAH0TIY0}];

# Stresses -ous of the earlier-defined OS class of adjectives.  
define OSFinalVowelStress [{AH0S} -> {AA1S} || _ {AH0TIY0}];

# Stresses final pre-ity vowels of all other -ity nouns.
define RESTFinalVowelStress ["0" -> "1" || _ [$.[ToUppercase.l]]^{0,2} {AH0TIY0}];

# Gives secondary stress to the fifth-to-last vowel.
define InitialVowelStress ["0" -> "2" || _ [[$.["0"|"1"]]^2 {AH0TIY0}]];

# Composition of each set of rules.
define ALTransform UFormAL .o. VowelDestress .o. ALFinalVowelStress .o. InitialVowelStress;
define ILETransform UFormILE .o. VowelDestress .o. ILEFinalVowelStress .o. InitialVowelStress;
define OSTransform UFormOS .o. VowelDestress .o. OSFinalVowelStress .o. InitialVowelStress; 
define RESTTransform UFormREST .o. OUSDeletion .o. VowelDestress .o. RESTFinalVowelStress .o. InitialVowelStress;

# Maps orthographic -ity adjectives to their corresponding phonetic noun form.
define FinalTransform ALTransform | ILETransform | OSTransform | RESTTransform;


## 5c.

# The set of all -ity nouns in the N dictionary that are not in the CMU dictionary.
define NonCMUNouns [N .o. ToUppercase].l & [?* {ITY}] & ~[CMU.u];

# Maps -able and -ible from their noun forms in final context. 
define ABLEAdjective [{IBILITY} -> {IBLE}, {ABILITY} -> {ABLE}||_ .#.];

# Maps -e from its noun forms in final context.
define EAdjective [{URITY} -> {URE}, {UDITY} -> {UDE}, {QUITY} -> {QUE}, {INITY} -> {INE}, {AVITY} -> {AVE}|| .#.];

# Maps -ous from its noun forms in final context.
define OUSAdjective [{UITY} -> {UOUS}, {OSITY} -> {OUS}, {ACITY} -> {ACIOUS}, {NIMITY} -> {NIMOUS}|| .#.];

# Deletes -ity in final context.
define RESTAdjective [{ITY} -> 0 || .#.];

# Composition of all phonological rules mapping nouns to adjectives.
define ToAdjective NonCMUNouns .o. ABLEAdjective .o. EAdjective .o. OUSAdjective .o. RESTAdjective;

# Orthographic -ity adjectives not in the CMU dictionary.
define NonCMUAdjectives ToAdjective.l & [A .o. ToUppercase].l;

# Maps -ity adjectives not in the CMU dictionary to phonetic noun form. 
define PhoneticTransform NonCMUAdjectives .o. FinalTransform;

# Maps orthographic -ity nouns not in the CMU dictionary to phonetic form. 
define PhoneticNouns ToAdjective .o. PhoneticTransform;

# Adds phonetic -ity nouns to the CMU dictionary.
define NewCMU CMU | PhoneticNouns;
