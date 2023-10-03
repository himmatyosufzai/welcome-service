import random

# List of possible hiding places with riddles
hiding_places = {
    "Living room": [
        "A space to relax, but not to sleep.",
        "You'll find a couch and TV, but not a bed.",
        "Where the family gathers to take a seat.",
        "Not for cooking, but entertainment instead.",
        "You might find a remote, but not a spoon."
    ],
    "Kitchen": [
        "A room where meals begin and end.",
        "Pots and pans, oven's best friend.",
        "Not a place you'd usually sleep in.",
        "Fridge and freezer reside herein.",
        "Cook here, but don't take a bath."
    ],
    "Bathroom": [
        "Water flows, but it's not a river.",
        "Not for cooking, but might make you shiver.",
        "A tub, a sink, and maybe a mat.",
        "Where you go for a quick spat.",
        "Find a toilet, but not a chair."
    ],
    "Pantry": [
        "Stored but not cooked is the food you seek.",
        "Closed shelves, secrets they keep.",
        "Dry goods' place, in a nook or cranny.",
        "Not a fridge, but some might keep a granny!",
        "Canned goods sit, waiting their time."
    ],
    "Kid's Bedroom": [
        "Toys galore, scattered on the floor.",
        "Stories and dreams, where imagination soars.",
        "Not a chef's domain, but maybe a tiny chef's hat.",
        "Crayons and drawings, and maybe a pet cat.",
        "You might find a teddy, but not a TV remote."
    ],
    "Master Bedroom": [
        "Sleep and rest, where two might nest.",
        "Larger than the kid's, it's often the best.",
        "A closet with clothes, shoes and a hat.",
        "No toys here, but perhaps a pet cat.",
        "A bed for two, but no oven to bake."
    ],
    "Balcony": [
        "Above the ground, where fresh air is found.",
        "Flowers might bloom, while you assume.",
        "A view of the sky, but not a place to fry.",
        "You might have a chair, to take in fresh air.",
        "Outdoors, yet a part of the house's layers."
    ],
    "Garage": [
        "Cars reside, tools on the side.",
        "Not a place for a bed, but maybe a sled.",
        "Oil and grease, but not a place for geese.",
        "Wheels and engines, and maybe some benches.",
        "You might find a bike, but not a mike."
    ],
    "Backyard": [
        "Green and wide, under the open sky.",
        "Grass and trees, with maybe some bees.",
        "A place for a BBQ, and a game or two.",
        "Not indoors, but has many outdoorsy lures.",
        "You might find a swing, where birds might sing."
    ]
}

# Randomly choose the hiding place
hidden_location = random.choice(list(hiding_places.keys()))
current_riddle_index = 0

attempts = 3

print("Welcome to the Hide and Seek Game with Riddles!")
print("Here are the possible hiding places:")
for place in hiding_places:
    print(f"- {place}")

print("\nYou have 3 attempts to guess where the hidden player is.")

guessed_locations = []
remaining_attempts = attempts

while remaining_attempts > 0:
    print(f"\nAttempts remaining: {remaining_attempts}")
    guess = input("Enter your guess: ")

    guess_normalized = guess.lower().replace(" ", "")

    if guess_normalized in [place.lower().replace(" ", "") for place in hiding_places]:
        if guess_normalized == hidden_location.lower().replace(" ", ""):
            print("Congratulations! You found the hidden player.")
            break
        elif guess_normalized in guessed_locations:
            print(
                f"You already searched {guess}. The hidden player is not there.")
        else:
            guessed_locations.append(guess_normalized)
            remaining_attempts -= 1

            if remaining_attempts < 2:
                print(
                    f"Riddle: {hiding_places[hidden_location][current_riddle_index]}")
                current_riddle_index = (current_riddle_index + 1) % 5
            else:
                print("Incorrect guess. Try again.")
    else:
        print(f"No such location. Here are the possible locations:")
        for place in hiding_places:
            print(f"- {place}")

else:
    print(
        f"\nSorry, you've used all {attempts} attempts. The hidden player was in {hidden_location}.")
    print("Hidden player wins!")
