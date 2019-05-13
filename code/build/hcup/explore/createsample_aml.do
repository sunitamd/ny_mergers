//enables to be replicated exactly
set seed 796499

local sampsize 1827964 

// tag 1 observation from each visitlink
bys visitlink: gen visit_tag = _n==1

// generate random number in a way that can be replicated if necessary
bys visit_tag (daystoevent): gen rn = runiform()

// randomly select the desired number of visitlinks by sorting tagged visitlink
//    obervations on the previously generated random number
bys visit_tag (rn): gen select = (visit_tag == 1) & (_n <= `sampsize')

// extend select indicator to all observations for the selected visilink, ordering them by both visitlink and daystoevent
bys visitlink (daystoevent): replace select = sum(select)
bys visitlink (daystoevent): replace select = select[_N]

keep if select==1
