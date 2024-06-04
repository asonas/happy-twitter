import React, { useState, useEffect } from 'react';
import axios from 'axios';
import TweetCard from './TweetCard';

const TweetList = ({ query }) => {
  const [tweets, setTweets] = useState([]);

  useEffect(() => {
    const fetchTweets = async () => {
      try {
        const res = await axios.get(query ? `/search?query=${query}` : '/');
        setTweets(res.data.tweets);
      } catch (error) {
        console.error(error);
      }
    };

    fetchTweets();
  }, [query]);

  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {tweets.map((tweet) => (
        <TweetCard key={tweet.id} tweet={tweet} />
      ))}
    </div>
  );
};

export default TweetList;
