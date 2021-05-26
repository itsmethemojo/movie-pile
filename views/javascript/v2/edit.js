function removeOldestPileEntry(entries){
  oldest_date=Date.now()
  oldest_key=null
  entries.forEach(key => {
    if(entries[key].last_edited < oldest_date) {
      oldest_date = entries[key].last_edited;
      oldest_key = key;
    }
  });
  delete entries[oldest_key];
}

function addPileToLatestList(url, name){
  try {
    movie_piles_data = JSON.parse(window.localStorage.getItem("movie_piles_data"));
  }
  finally {
    if (movie_piles_data === null){
      movie_piles_data = {};
    }
  }
  movie_piles_data[url] = {
    name: name,
    last_edited: Date.now()
  };
  if(Object.entries(movie_piles_data).length > 10){
    removeOldestPileEntry(movie_piles_data);
  }
  window.localStorage.setItem("movie_piles_data", JSON.stringify(movie_piles_data));
}

function initClipboardButton() {
  var clipboard_button = document.getElementById("clipboard-button")
  var clipboard_button_feedback = document.getElementById("clipboard-button-feedback")
  clipboard_button.addEventListener('click', () => {
    var clipboard = navigator.clipboard || window.clipboard
    var share_url = document.getElementById("movie-pile-share-url").textContent

    clipboard.writeText(share_url)
      .then(() => { clipboard_button_feedback.textContent = '✔' })
      .catch(() => { clipboard_button_feedback.textContent = '❌' })
      .then(() => setTimeout(() => { clipboard_button_feedback.textContent = '' }, 1500))
  })
}

function init(){
  initClipboardButton();
  var request = new XMLHttpRequest();
  request.open( "GET", "<%= data['api_url'] %>", false );
  request.send( null );
  var movie_pile = JSON.parse(request.responseText);
  var moviesInputHtml = "";
  movies = movie_pile['movie_list'];
  for (var i = 0; i < movies.length; i++) {
    moviesInputHtml += '<p><span>' + movies[i].title + '</span><br/><input type="text" value="' + movies[i].url + '"/></p>';
  }
  document.getElementById("movie-pile-section").innerHTML = moviesInputHtml;
  document.getElementById("movie-pile-name").value = movie_pile['name'];
  addPileToLatestList(window.location.href, movie_pile['name']);
}

init();
function addMovie(){
  var nextUrlInput = document.createElement("input");
  nextUrlInput.type = "text";
  nextUrlInput.value = "";
  var wrapper = document.createElement("p");
  wrapper.appendChild(nextUrlInput);
  document.getElementById("movie-pile-section").appendChild(wrapper);
}

function saveMovie(){
  name = document.getElementById("movie-pile-name").value;
  secret = document.getElementById("movie-pile-secret").value;
  movie_list = [];
  document.querySelectorAll("section#movie-pile-section p input").forEach(input => {
    movie_entry = input.value.trim();
    if(movie_entry !== "") {
      movie_list.push(movie_entry);
    }
  });
  var request = new XMLHttpRequest();
  request.open( "POST", "<%= data['api_url'] %>", false );
  request.setRequestHeader('TOKEN', secret);
  request.send(
    JSON.stringify(
      {
        name: name,
        movie_list: movie_list
      }
    )
  );
  var feedback = document.getElementById("saving-feedback");
  feedback.textContent = "✔ Saved successfully";
  setTimeout(() => { feedback.textContent = '' }, 1500);
}
