# Tier 1 ingredients with their base scores
T1_INGREDIENTS = {
    'sugar': 50,
    'salt': 50,
    'coffee': 75,
    'soda': 60,
    'vodka': 150,  # Higher score for vodka
    'rum': 150,    # Higher score for rum
    'berry': 80,
    'mint': 70,
    'water': 40,
    'lemon': 60
}

# Tier 2 ingredients and their T1 constituents
T2_INGREDIENTS = {
    'syrup': ['sugar', 'water'],
    'berry_syrup': ['sugar', 'water', 'berry'],
    'lemon_soda': ['lemon', 'soda']
}

class DrinkMixer:
    def __init__(self):
        self.main_mix = []  # Main drink mix
        self.t2base_mix = []  # T2 base mix
        self.base_score = 500
        self.ingredient_bank = set()  # Initial bank of ingredients
        
    def add_ingredient(self, ingredient, mix_type='main'):
        """Add ingredient to specified mix type. Only ingredients from ingredient bank are allowed."""
        if ingredient not in self.ingredient_bank:
            raise ValueError(f"{ingredient} is not available in your ingredient bank")
            
        # For main mix, allow both T1 and T2 ingredients
        if mix_type == 'main':
            self.main_mix.append(ingredient)
            self.ingredient_bank.remove(ingredient)  # Remove from bank when used
        # For t2base mix, only allow T1 ingredients
        else:
            if ingredient not in T1_INGREDIENTS:
                raise ValueError(f"{ingredient} is not a valid T1 ingredient for base mix")
            self.t2base_mix.append(ingredient)
            self.ingredient_bank.remove(ingredient)  # Remove from bank when used
            # Check if we can create any T2 ingredients
            self.check_and_create_t2()
            
    def check_and_create_t2(self):
        """Check if current t2base_mix can create any T2 ingredients"""
        for t2_name, required_ingredients in T2_INGREDIENTS.items():
            # Check if all required ingredients are in t2base_mix
            if all(ing in self.t2base_mix for ing in required_ingredients):
                # Remove used ingredients
                for ing in required_ingredients:
                    self.t2base_mix.remove(ing)
                # Add the created T2 ingredient to ingredient bank
                self.ingredient_bank.add(t2_name)

    def set_initial_bank(self, ingredients):
        """Set the initial bank of ingredients available to the player"""
        for ingredient in ingredients:
            if ingredient not in T1_INGREDIENTS and ingredient not in T2_INGREDIENTS:
                raise ValueError(f"{ingredient} is not a valid ingredient")
        self.ingredient_bank = set(ingredients)
    
    def calculate_t1_score(self, ingredients, target_ingredients):
        """Calculate score for T1 ingredients"""
        score = 0
        for ing in ingredients:
            if ing in T1_INGREDIENTS and ing in target_ingredients:
                score += T1_INGREDIENTS[ing]
        return score
    
    def count_t2_ingredients(self, mix):
        """Count number of T2 ingredients in mix"""
        return sum(1 for ing in mix if ing in T2_INGREDIENTS)
    
    def get_t2_multiplier(self, t2_count):
        """Get multiplier based on T2 ingredient count"""
        if t2_count == 1:
            return 1.5
        elif t2_count == 2:
            return 2.0
        elif t2_count >= 3:
            return 3.0
        return 1.0
    
    def calculate_total_score(self, target_ingredients):
        """Calculate total score including base, T1 scores and T2 multipliers"""
        # Start with base score
        total_score = self.base_score
        
        # Add T1 ingredient scores
        t1_score = self.calculate_t1_score(self.main_mix, target_ingredients)
        total_score += t1_score
        
        # Apply T2 multiplier
        t2_count = self.count_t2_ingredients(self.main_mix)
        multiplier = self.get_t2_multiplier(t2_count)
        
        return total_score * multiplier

# Example usage
if __name__ == "__main__":
    # Create a new drink mixer
    mixer = DrinkMixer()
    
    # Set initial ingredient bank
    initial_ingredients = ['vodka', 'sugar', 'berry', 'water']
    mixer.set_initial_bank(initial_ingredients)

    # Example target ingredients
    target = ['vodka', 'sugar', 'berry', 'water']
    
    # Add T1 ingredients to create syrup in t2base_mix
    mixer.add_ingredient('sugar', 't2base')
    mixer.add_ingredient('water', 't2base')  # This will create syrup and add it to bank
    
    # Add other ingredients to main mix
    mixer.add_ingredient('vodka')
    mixer.add_ingredient('berry')
    mixer.add_ingredient('syrup')
    
    # Calculate and display score
    final_score = mixer.calculate_total_score(target)
    print(f"Final Score: {final_score}")
    print(f"Main mix: {mixer.main_mix}")
    print(f"T2 base mix: {mixer.t2base_mix}")
    print(f"Ingredient bank: {mixer.ingredient_bank}")