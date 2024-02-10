String[] pokemonNames;
boolean[] winnerGuessed;
PImage[] imgs;
int[] pokemonSpeed;
int limit = 8;
int offset;
float sX = 0;
float imgWidth, posX;
boolean start = false;
boolean winner = false;
String winnerName;
int yDifference = 100;
boolean showPokemonName = false;


void setup() {
  size(900, 800);
  background(240, 246, 246);
  offset = int(random(0, 100));

  pokemonNames = new String[limit];
  pokemonSpeed = new int[limit];
  winnerGuessed = new boolean[pokemonNames.length];
  imgs = new PImage[limit];

  String apiUrl = String.format("https://pokeapi.co/api/v2/pokemon?offset=%s&limit=%s", offset, limit);
  JSONObject json = loadJSONObject(apiUrl);
  JSONArray pokemon = json.getJSONArray("results");

  for (int i = 0; i < limit; i++) {
    // Save each pokemon name to pokemonNames array.
    pokemonNames[i] = pokemon.getJSONObject(i).getString("name");

    String speedUrl = String.format("https://pokeapi.co/api/v2/pokemon/%s", pokemonNames[i]);
    JSONObject jsonPokemon = loadJSONObject(speedUrl);
    JSONArray stats = jsonPokemon.getJSONArray("stats");
    JSONObject sprites = jsonPokemon.getJSONObject("sprites");

    imgs[i] = loadImage(sprites.getString("front_default"));

    // Set each pokemon a speed. Go through stats to find speed stat.
    for (int j = 0; j < stats.size(); j++) {
      if (stats.getJSONObject(j).getJSONObject("stat").getString("name").equals("speed")) {
        pokemonSpeed[i] = stats.getJSONObject(j).getInt("base_stat");
      };
    }
  }
}

void mouseClicked() {
  for (int i =  0; i < pokemonNames.length; i++) {
    if (mouseX > 0 && mouseX < imgs[i].width) {
        showPokemonName = true;
      if (mouseY > i * yDifference && mouseY < i * yDifference + imgs[i].height) {  
        winnerGuessed[i] = !winnerGuessed[i];
      } else {
        // Make all others false when one is picked.
        winnerGuessed[i] = false;
      }
    }
  }
}

void keyPressed() {
  if (keyPressed) {
    if (key == 32) {
      
      if (start) {
        start = false;
        showPokemonName = false;
      }
      if (!start && showPokemonName) {
        start = true;
      }
    }
  }
}

boolean checkIfCorrect() {
  // Have to initialise the index, so setting it as -1 which will never result to true.
  int winnerGuessedIndx = -1;
  for (int i =  0; i < pokemonNames.length; i++) {
    if (winnerGuessed[i]==true) {
      winnerGuessedIndx = i;
    }
  }

  if (pokemonNames[winnerGuessedIndx] == winnerName) {
    return true;
  } else {
    return false;
  }
}

void draw() {
  background(240, 246, 246);
  textAlign(CENTER);
  textSize(60);

  if (start ) {
    // Stop movement of all when winner is found.
    if (winner) {
      text("The winner was " + winnerName + " !", width/2, height/2);
      fill(66, 191, 221);
      if (checkIfCorrect()) {
        text("You won!!", width/2, height/2 + 70);
      } else {
        text("You lost!!", width/2, height/2 + 70);
      }
      sX += 0;
    } else {
      sX += 0.05;
    }

    for (int i =  0; i < pokemonNames.length; i++) {
      textSize(40);
      posX = pokemonSpeed[i] * sX;
      imgWidth = imgs[i].width;
      if (posX + imgWidth >= width && !winner) {
        // Stop movement
        posX = width - imgWidth;
        // Save name of the winner.
        winnerName = pokemonNames[i];
        winner = true;
      }

      image(imgs[i], posX, i * yDifference);
    }
  } else {
    fill(255, 102, 179);

    // Empty variables
    posX = 0;
    sX = 0;
    winner = false;
    winnerName = "";

    text("Click on the Pokémon", width/2, height/2  - 120);
    text("to guess the winner and", width/2, height/2  - 60);
    text("press the spacebar", width/2, height/2);
    text("to make them race!", width/2, height/2 + 60);
    textSize(15);
    text("Note that a quick click may not select the desired Pokemón. Good things take time.", width/2, height/2 + 85);
    for (int i =  0; i < pokemonNames.length; i++) {
      image(imgs[i], posX, i * yDifference);
      fill(66, 191, 221);
      textSize(40);
      if ( winnerGuessed[i]==true && showPokemonName ) text(pokemonNames[i], width/2, height/2 + 120);
    }
  }
}
