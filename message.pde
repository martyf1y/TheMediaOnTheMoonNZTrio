
void updateMessage() {
  if (wordTimer < millis()-wordEndTime) {
    if (!waitType && !runAway) {
      newColor = QColor[int(random(0, 7))];
      thisTwit = defaultMessage[int(random(0, 6))];
      if(goAgain){
      newTweet = getNewTweets();
      }
      if (newTweet) {
        
        String finalTwit = theTweets[currentTweet];
        //currentTweet = currentTweet + 1;
        if (finalTwit == null) {
          thisTwit = defaultMessage[int(random(0, 6))];
        } else {
          thisTwit = finalTwit;  
          notweets = false;
          goFree = false;
          tweetCounter ++;
           if (maskSize >= moonAdjust && changeMoon) {
            goFree = true;
           }
        }
        nextWord(thisTwit);
      } else {
        goFree = true;
        
        if (wordTimer < millis()-wordEndTime-40000){ // Show random old message
          String Tlines[] = loadStrings("tweets.txt"); 
          if(Tlines.length >= 1){
          thisTwit = Tlines[int(random(0, Tlines.length-4))];
          }
        }
        else if (longTimer < millis()-longEndTime) { // Change to default
        thisTwit = defaultMessage[int(random(0, 6))];
        longTimer = millis();
        }
        else if(hourTimer == hour()){ // Change to default with addition moon
          if(notweets){
          goFree = false;
          checkHour ++;
          notweets = false;
          thisTwit = defaultMessage[int(random(0, 6))];
          println("HOUR: "+ checkHour + " " + hourTimer);
          hourTimer = hour() + 2;
          if(hourTimer >= 24){
            hourTimer = 0;
          }
          }
        }
        else if(hourTimer == hour()+1 && !notweets){ // Change back addition to reset
           notweets = true;
           println("Reset: "+ checkHour);
        }
        else{
          return;
        }
        nextWord(thisTwit);
    }
      stringCount = 0;
      //nextWord(thisTwit);
      waitType = true;
    } else {
      waitType = false;
      goAgain = true;
    }
  }
  if (waitType && !runAway) {    
    runAway = printMessage();
  }
}


boolean printMessage() {
  if (stringCount < thisTwit.length()) {
    stringCount ++; 
    String typeTwit = thisTwit.substring(0, stringCount);
    message = typeTwit;
  } else if (stringCount >= thisTwit.length()) {
    return true;
  }
  //delay(40);
  return false;
}

boolean getNewTweets() {
  goAgain = false;
  try {
    // try to get tweets here
    Query query = new Query(searchString);
    query.setCount(30); 

     QueryResult result = twitter.search(query);
    //tweets = twitter.getUserTimeline(searchString);
    tweets = result.getTweets();
    int i = 0;
    for (Status status : tweets) {
      //  System.out.println("@" + status.getUser().getScreenName() + ":" + status.getText());
      String lowercase = status.getText();
      lowercase = lowercase.toLowerCase();
      //theTweets[i] = "";
      if (lowercase.indexOf("#glow")>=0) {
        theTweets[i] = "@" + status.getUser().getScreenName() + " - " + status.getText();
       // println("GOT IT " + theTweets[i]);
        i++;
      }
    }

    // loadt text file
    String Tlines[] = loadStrings("tweets.txt");    
    if (theTweets[0] == "" || theTweets[0] == null) {
      return false; // no tweets
    } 
    else if (Tlines.length <= 0) {
      currentTweet = i-1;
      Tlines = splice(Tlines, theTweets[i-1], 0);//Welcome to the club!!!
      saveStrings("tweets.txt", Tlines); 
      return true; // yay new tweet!
    }
    boolean allnew = true;
    for (int tw = 0; tw < theTweets.length; tw++) { // We check all the tweets, but only up to when they are the same
      for (int tx = 0; tx < Tlines.length; tx++) {
        // check text starting from first
        // if found stop, take previous one

      if(theTweets[tw] != null){
        if (theTweets[tw].equals(Tlines[tx])) {
          allnew = false;
          if (tw == 0) {
            return false; // nothing new here
          } else if (tw > 0) {
            currentTweet = tw-1;
            Tlines = splice(Tlines, theTweets[currentTweet], 0);//Welcome to the club!!!
            saveStrings("tweets.txt", Tlines);  
            return true; // yay new tweet!
          }
        }
      }
      else if(allnew && theTweets[currentTweet-1] != null){ /// Just before the null entry we found a new one
         currentTweet = tw-1;
            Tlines = splice(Tlines, theTweets[currentTweet], 0);//Welcome to the club!!!
            saveStrings("tweets.txt", Tlines);  
            return true;
      }
      }
    }
      
    //statuses = twitter.getUserTimeline(userName, page);
  }
  catch (TwitterException te) {
    // deal with the case where we can't get them here
    System.out.println("Failed to search tweets: " + te.getMessage());
   // System.exit(-1);
  }
  return false;
}