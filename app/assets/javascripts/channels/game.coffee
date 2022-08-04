jQuery(document).on 'turbolinks:load', ->

  collection = $('#game-board')
  if $('#game-user')
    user_id = $('#game-user').data('user-id')

  if typeof collection.data('game-id') != 'undefined' && collection.data('game-id')
    console.log('It entered into the data-channel')

  App.game = App.cable.subscriptions.create { channel: "GameChannel", game_id: collection.data('game-id') },
    connected: ->
      $('#game_status').html('You need to wait for second player, ')

    disconnected: ->
      @perform 'end_game', game_id: collection.data('game-id'), user_id: user_id

    received: (data) ->
      switch data.action
        when 'wrong_turn'
          alert 'Player input wrong box, try other box..!!'
        when 'new_game'
          $('#game_status').html('Player found, ')
        when 'game_start'
          $('#game_status').html('Game Started, ')
          $("#instructions").html('')
          html = ''
          i = 0
          j = 0
          arr = JSON.parse(JSON.stringify(data.game));
          while i < 3
            html += "<div class='row row-#{i+1}'>"
            while j < 3
              player = arr[i * 3 + j].box
              player_class = ''
              if player == 1
                player_class = 'player_1'
              else if player == 2
                player_class ='player_2'
              html += "<div class='col tile text-center #{player_class}' id='game-move-#{i*3+j+1}' style='cursor: pointer'></div>"
              ++j
            html+= "</div>"
            j = 0
            ++i
          collection.html(html)
        when 'with_draw'
          collection.html('Opponent withdraw, You win!')
          $("#instructions").html('')
        when 'connected'
          $('#game_status').html('Waiting for other player, ')
          alert 'Wait for other player!!'
        when 'result'
          if data.winner
            alert(data.user.name + ', Won')
          else if data.tie
            alert('It\'s Tie')
          if data.path
            window.location.pathname = data.path
          @perform 'end_game', game_id: data.game_id, user_id: data.user.id

    send_game: (game_id, user_id, move) ->
      @perform 'send_game', game_id: game_id, user_id: user_id, move: move

  $(document).on "click", "#game-board .tile", (e) ->
    e.preventDefault()
    move_id = $(this).attr("id")
    App.game.send_game collection.data('game-id'), user_id, move_id
    return false


