import React, { useState, useEffect } from 'react';
import axios from 'axios';
import TweetCard from './TweetCard';

const TweetList = ({ query }) => {
  const [tweets, setTweets] = useState([]);

  useEffect(() => {
    const fetchTweets = async () => {
      try {
        const res = await axios.get('http://10.0.2.200:4567/api/tweets');
        setTweets(res.data);
      } catch (error) {
        console.error(error);
      }
    };

    fetchTweets();
  }, [query]);

  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {tweets
        .filter(tweet => tweet.content.includes(query))
        .map((tweet) => (
          <TweetCard key={tweet.original_tweet_id} tweet={tweet} />
        ))}
    </div>
  );
};

export default TweetList;
