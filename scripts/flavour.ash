script "Auto-Flavour";
notify "Soolar the Second";

import <zlib.ash>;

float EPSILON = 0.00001;

boolean float_equals(float f1, float f2)
{
	return abs(f1 - f2) < EPSILON;
}

void main()
{
	if(!have_skill($skill[Flavour of Magic]) || !be_good($skill[Flavour of Magic]))
		return;
	
	setvar("flavour.perfectonly", false);
	
	float [element] double_damage;
	boolean [element] perfect;
	float [element] one_damage;
	
	foreach ele in $elements[cold, hot, sleaze, spooky, stench, none]
	{
		double_damage[ele] = 0;
		one_damage[ele] = 0;
		perfect[ele] = true;
	}
	
	boolean [element] weak_elements(element ele)
	{
		switch(ele)
		{
			case $element[cold]: return $elements[hot, spooky];
			case $element[spooky]: return $elements[hot, stench];
			case $element[hot]: return $elements[stench, sleaze];
			case $element[stench]: return $elements[sleaze, cold];
			case $element[sleaze]: return $elements[cold, spooky];
			default: return $elements[none];
		}
	}
	
	void handle_monster(monster mon, float chance)
	{
		if(chance == 0 || mon == $monster[none])
			return;
		
		boolean [element] weaknesses = weak_elements(mon.defense_element);
		
		foreach ele in $elements[cold, hot, sleaze, spooky, stench]
		{
			if(ele == mon.defense_element)
				one_damage[ele] += chance;
			
			if(weaknesses contains ele)
				double_damage[ele] += chance;
			else
				perfect[ele] = false;
		}
	}
	
	foreach mon,chance in appearance_rates(my_location(), true)
		handle_monster(mon, chance);
	
	element flavour = $element[none];
	float best_score = -1;
	float best_spell_damage = -99999;
	
	foreach ele in $elements[cold, hot, sleaze, spooky, stench]
	{
		float spell_damage = numeric_modifier(ele.to_string() + " Spell Damage");
		if(one_damage[ele] == 0 && ((double_damage[ele] > best_score) || (float_equals(double_damage[ele], best_score) && (spell_damage > best_spell_damage))))
		{
			flavour = ele;
			best_score = double_damage[ele];
			best_spell_damage = spell_damage;
		}
	}
	
	if(to_boolean(vars["flavour.perfectonly"]) && !perfect[flavour])
	{
		flavour = $element[none];
	}
	
	element current_flavour = $element[none];
	if(have_effect($effect[Spirit of Bacon Grease]) > 0)
		current_flavour = $element[sleaze];
	else if(have_effect($effect[Spirit of Garlic]) > 0)
		current_flavour = $element[stench];
	else if(have_effect($effect[Spirit of Cayenne]) > 0)
		current_flavour = $element[hot];
	else if(have_effect($effect[Spirit of Wormwood]) > 0)
		current_flavour = $element[spooky];
	else if(have_effect($effect[Spirit of Peppermint]) > 0)
		current_flavour = $element[cold];
	
	if(flavour != current_flavour)
	{
		switch(flavour)
		{
			case $element[none]:
				use_skill(1, $skill[Spirit of Nothing]);
				break;
			case $element[hot]:
				use_skill(1, $skill[Spirit of Cayenne]);
				break;
			case $element[cold]:
				use_skill(1, $skill[Spirit of Peppermint]);
				break;
			case $element[stench]:
				use_skill(1, $skill[Spirit of Garlic]);
				break;
			case $element[spooky]:
				use_skill(1, $skill[Spirit of Wormwood]);
				break;
			case $element[sleaze]:
				use_skill(1, $skill[Spirit of Bacon Grease]);
				break;
		}
	}
}