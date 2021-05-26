function init(){
  try {
    movie_piles_data = JSON.parse(window.localStorage.getItem("movie_piles_data"));
  }
  finally {
    if (movie_piles_data === null){
      movie_piles_data = {};
    }
  }
  if(Object.entries(movie_piles_data).length > 0){
    html = '<h2> your piles</h2>';
    Object.keys(movie_piles_data).forEach(movie_pile_url => {
       html += '<p><a href="' + movie_pile_url + '">' + movie_piles_data[movie_pile_url].name + '</a></p>'
    });
    document.getElementById("existing-movie-piles").innerHTML = html;
  }
}

init();

function start(){
  var request = new XMLHttpRequest();
  request.open( "POST", "/api/v2/movie-pile/create", false );
  request.setRequestHeader('Content-Type', 'application/json');
  request.setRequestHeader('Accept', 'application/json');
  request.send(
    JSON.stringify(
      {
        name: "Movie Pile " + new Date().toISOString().slice(0, 10),
        movie_list: []
      }
    )
  );
  var movie_pile = JSON.parse(request.responseText);
  window.location.href= '/v2/' + movie_pile['id'] + '/edit/' + movie_pile['secret'];
}
