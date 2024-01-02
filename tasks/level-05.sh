#!/bin/sh

. ./lib.sh

init_level
init_root "$1"
exec 2> README

next_task # 1 static script
(
word="$(random_alnum)"
prepare_current_token  "hello $word"
task "Create an $(bold executable script file) which writes $(bold "'hello $word'") (without quotes) to $(bold standard output). Get the token by running: $(bold "$(print_check exec)") $(underlined ./your_script)"
)

next_task # 2 positional parameters
(
word() { random_alnum; }
word1="$(word)"
word2="$(word)  $(word)"
prepare_current_token "$(printf 'hello %s\nhello %s\n' "$word1" "$word2")"
task "Create an $(bold executable script file) which writes $(underlined "'hello XXXX'") (without quotes) to $(bold standard output) ($(underlined XXXX) shall be the first argument passed to the script). The script must print arguments with spaces $(bold verbatim) (i.e. ./script 'a  b' outputs 'hello a  b'). Get the token by running: $(bold "$(print_check hello)") $(underlined ./your_script "'$word1'" "'$(word)'" "'$word2'" "'$(word)'")"
)

# pizza:
(
sort > meats <<EOF
ham
bacon
pepperoni
suçuk
kebab
minced meat
meatballs
sausage
tuna
anchovies
shrimps
calamari
clams
chorizo
EOF

sort > vegetables <<EOF
mozarella
gorgonzola
goat cheese
tomatoes
mushrooms
olives
onions
artichokes
pineapple
corn
egg
broccoli
jalapeños
garlic
bell peppers
EOF

sort > extras <<EOF
stuffed crust
basil
truffles
birthday candles
sour cream
avocados
EOF

names="$(mktemp)"
shuf > "$names" <<EOF
credo
crustlust
mario
luigi
peach
donatello
raffaelo
da vinci
lavinya
maria
gamba
pingvin
slim
thick
avalon
extravaganza
crunchy
picante
virgine
david
giovanni
andrea
picasso
underground
cheesus chrust
another one bites the crust
pepperazi
pizzachu
calzogne
breach of crust
american pie
pie hard
hot'n'cold
three one four
EOF

pizza() {
	mktoken="$1"
	{
		{
			total="$(random_int 4 8)"
			sub="$(random_int 1 "$((total-1))")"
			shuf -n"$sub" "$2"
			shuf -n"$((total-sub))" "$3"
			test "$4" && cat "$4"
		} | shuf | join_lines ','
		"$mktoken"
	} | join_lines '\t'
}

file="$(uniq_filename)"

yummy="$(mktemp)"
cat extras | shuf -n"$(random_int 2 4)" > "$yummy"
yucky="$(mktemp)"
shuf -n"$(random_int 4)" > "$yucky" <<EOF
gummy bears
snails
ketchup
spaghetti
EOF

pretty() {
	awk '
		NR>1{printf sep line;sep=", "}
		{line=$0}
		END{
			if(NR==2)sep=" and "
			if(NR>2)sep=sep"and "
			print sep line
		}
	' "$@"
}

{
info "The file '$file' contains a list of pizzas together with their ingredients.
"

next_task # 3 pizza vegetarian
repeat "$(random_int 2 8)" pizza current_token vegetables vegetables
repeat "$(random_int 2 8)" pizza current_fake_token vegetables meats
task "The token is next to a $(bold vegetarian) pizza. You can find a list of meat-based ingredients in the file $(bold meats)."

next_task # 4 pizza extras
repeat "$(random_int 2 8)" pizza current_token vegetables meats "$yummy"
repeat "$(random_int 2 4)" pizza current_fake_token meats "$yucky" "$yummy"
repeat "$(random_int 2 4)" pizza current_fake_token vegetables "$yucky" "$yummy"
task "You cannot decide which pizza to order. You $(bold love) $(pretty "$yummy"); but you $(bold can not) stand $(pretty "$yucky"). The token is next to your favorite pizzas."
} | shuf | paste "$names" - | grep -e "$COURSE{.*}" > "$file"
)
repeat 2 next_task # re-apply task from subshell to parent shell
