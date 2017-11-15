const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.createMovesKey = functions.database.ref('/games/{gameKey}')
 .onCreate(event => {
   event.data.ref.child("round").set(0);
   event.data.ref.child("status").set(randomCoins());
});

exports.gameDidUpdate = functions.database.ref('/games/{gameKey}')
 .onUpdate(event => {
   var gameDetails = event.data.val()


   var firstPlayerUID = ""
   var firstPlayerMoves = ""
   var firstPlayerBet = 0

   var secondPlayerUID = ""
   var secondPlayerMoves = ""
   var secondPlayerBet = 0

   var round = gameDetails["round"]
   var status = gameDetails["status"]

   var root = admin.database().ref()
   var count = 0

   for(var key in gameDetails) {
      count = count + 1
     if (firstPlayerMoves == "") {
        firstPlayerUID = key
        firstPlayerMoves = gameDetails[key]["move"]
        firstPlayerBet = gameDetails[key]["bet"]
     } else if (secondPlayerMoves == "") {
       secondPlayerUID = key
       secondPlayerMoves = gameDetails[key]["move"]
       secondPlayerBet = gameDetails[key]["bet"]
     }
   }

   if (count == 2) {
      return root.child(`games/${event.params.gameKey}`).remove()
   }

   // starting the game
   if (round == 0) {
     if (firstPlayerBet != 0 && secondPlayerBet != 0) {
       return event.data.ref.child("round").set(1)
     }
   }

   if ((firstPlayerMoves.length == round) && (secondPlayerMoves.length == round)) {
     round = round + 1
     return event.data.ref.child("round").set(round)
   }

   if (round == 6) {
     var firstPlayerCoins = 0
     var secondPlayerCoins = 0

     var firstPlayerScore = score(status, firstPlayerMoves)
     var secondPlayerScore = score(status, secondPlayerMoves)

     return root.child(`users/${firstPlayerUID}/coins`).once('value').then(snap => {
        firstPlayerCoins = snap.val()
        return root.child(`users/${secondPlayerUID}/coins`).once('value')
     }).then(snap => {
       secondPlayerCoins = snap.val()

       // TODO: - Use concurrent promises
       //         * You can change the firstPlayersCoins and secondPlayersCoins at the same time
       if (firstPlayerScore > secondPlayerScore) {
         return root.child(`users/${firstPlayerUID}/coins`).set(firstPlayerCoins + firstPlayerBet)
       } else if (secondPlayerScore > firstPlayerScore) {
         return root.child(`users/${secondPlayerUID}/coins`).set(secondPlayerCoins + secondPlayerBet)
       }
     }).then(snap => {
       if (firstPlayerScore > secondPlayerScore) {
         return root.child(`users/${secondPlayerUID}/coins`).set(secondPlayerCoins - secondPlayerBet)
       } else if (secondPlayerScore > firstPlayerScore) {
         return root.child(`users/${firstPlayerUID}/coins`).set(firstPlayerCoins - firstPlayerBet)
       }
     }).then(snap => {
       return root.child(`games/${event.params.gameKey}`).remove()
     })
   }

  return 0
 });



function randomCoins() {
 var coins = ""

 for(var i = 1; i <= 5; i++) {
   var randomNumber = Math.floor(Math.random() * 2) + 1

   if (randomNumber == 1) {
     coins = coins.concat("H")
   } else {
     coins = coins.concat("T")
   }
 }

 return coins
}

function score(movesKey, moves) {
  var score = 0

  for(var i = 0; i < movesKey.length; i++) {
    if (movesKey[i] == moves[i]) {
      score = score + 1
    }
  }

  return score
}
