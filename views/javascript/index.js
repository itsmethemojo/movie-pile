/*jshint esversion: 6 */

function init() {
  try {
    moviePileData = JSON.parse(window.localStorage.getItem('movie_piles_data'));
  }
  finally {
    if (moviePileData === null) {
      moviePileData = {};
    }
  }
  if (Object.entries(moviePileData).length > 0) {
    html = '<h2> your piles</h2>';
    Object.keys(moviePileData).forEach(moviePileUrl => {
      html += '<p><a href="' +
        moviePileUrl + '">' +
        moviePileData[moviePileUrl].name +
        '</a></p>';
    });
    document.getElementById('existing-movie-piles').innerHTML = html;
  }
}

init();

function start() {
  var request = new XMLHttpRequest();
  request.open('POST', '/api/v2/movie-pile/create', false);
  request.setRequestHeader('Content-Type', 'application/json');
  request.setRequestHeader('Accept', 'application/json');
  request.send(
    JSON.stringify(
      {
        'name': 'Movie Pile ' + new Date().toISOString().slice(0, 10),
        'movie_list': []
      }
    )
  );
  var moviePile = JSON.parse(request.responseText);
  window.location.href = '/v2/' + moviePile.id + '/edit/' + moviePile.secret;
}
