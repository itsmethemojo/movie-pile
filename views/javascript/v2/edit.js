/*jshint esversion: 6 */

function removeOldestPileEntry(entries) {
  oldestDate = Date.now();
  oldestKey = null;
  entries.forEach(key => {
    // jscs:disable requireCamelCaseOrUpperCaseIdentifiers
    if (entries[key].last_edited < oldestDate) {
      oldestDate = entries[key].last_edited;
      oldestKey = key;
    }
    // jscs:enable requireCamelCaseOrUpperCaseIdentifiers
  });
  delete entries[oldestKey];
}

function addPileToLatestList(url, name) {
  try {
    moviePilesData = JSON.parse(
      window.localStorage.getItem('movie_piles_data')
    );
  }
  finally {
    if (moviePilesData === null) {
      moviePilesData = {};
    }
  }
  moviePilesData[url] = {
    'name': name,
    'last_edited': Date.now()
  };
  if (Object.entries(moviePilesData).length > 10) {
    removeOldestPileEntry(moviePilesData);
  }
  window.localStorage.setItem(
    'movie_piles_data',
    JSON.stringify(moviePilesData)
  );
}

function initClipboardButton() {
  var clipboardButton = document.getElementById('clipboard-button');
  var clipboardButtonFeedback = document.getElementById(
    'clipboard-button-feedback'
  );
  clipboardButton.addEventListener('click', () => {
    var clipboard = navigator.clipboard || window.clipboard;
    var shareUrl = document.getElementById('movie-pile-share-url').textContent;

    clipboard.writeText(shareUrl)
      .then(() => { clipboardButtonFeedback.textContent = '✔'; })
      .catch(() => { clipboardButtonFeedback.textContent = '❌'; })
      .then(() => setTimeout(() => {
        clipboardButtonFeedback.textContent = '';
      }, 1500));
  });
}

function initShowButton() {
  var showButton = document.getElementById('show-button');
  showButton.addEventListener('click', () => {
    window.location.href = document.getElementById(
      'movie-pile-share-url'
    ).textContent;
  });
}

function init() {
  initClipboardButton();
  initShowButton();
  var request = new XMLHttpRequest();
  request.open('GET', '<%= data["api_url"] %>', false);
  request.send(null);
  var moviePile = JSON.parse(request.responseText);
  var moviesInputHtml = '';
  // jscs:disable requireCamelCaseOrUpperCaseIdentifiers
  movies = moviePile.movie_list;
  // jscs:enable requireCamelCaseOrUpperCaseIdentifiers
  for (var i = 0; i < movies.length; i++) {
    moviesInputHtml += '<p><span>' +
      movies[i].title +
      '</span><br/><input type="text" value="' +
      movies[i].url +
      '"/></p>';
  }
  document.getElementById('movie-pile-section').innerHTML = moviesInputHtml;
  document.getElementById('movie-pile-name').value = moviePile.name;
  addPileToLatestList(window.location.href, moviePile.name);
}

init();
function addMovie() {
  var nextUrlInput = document.createElement('input');
  nextUrlInput.type = 'text';
  nextUrlInput.value = '';
  var wrapper = document.createElement('p');
  wrapper.appendChild(nextUrlInput);
  document.getElementById('movie-pile-section').appendChild(wrapper);
}

function saveMovie() {
  name = document.getElementById('movie-pile-name').value;
  secret = document.getElementById('movie-pile-secret').value;
  movieList = [];
  document.querySelectorAll('section#movie-pile-section p input').forEach(
    input => {
      movieEntry = input.value.trim();
      if (movieEntry !== '') {
        movieList.push(movieEntry);
      }
    });
  var request = new XMLHttpRequest();
  request.open('POST', '<%= data["api_url"] %>', false);
  request.setRequestHeader('TOKEN', secret);
  request.send(
    JSON.stringify(
      {
        'name': name,
        'movie_list': movieList
      }
    )
  );
  var feedback = document.getElementById('saving-feedback');
  feedback.textContent = '✔ Saved successfully';
  setTimeout(() => { feedback.textContent = ''; }, 1500);
}
