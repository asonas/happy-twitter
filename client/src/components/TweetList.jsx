import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import TweetCard from './TweetCard';

const TweetList = ({ query }) => {
  const [tweets, setTweets] = useState([]);
  const [offset, setOffset] = useState(0);
  const [isLoading, setIsLoading] = useState(false);

  const fetchTweets = useCallback(async (newOffset) => {
    setIsLoading(true);

    try {
      const res = await axios.get(`http://10.0.2.200:4567/api/tweets?offset=${newOffset}`);
      setTweets((prevTweets) => [...prevTweets, ...res.data]);
    } catch (error) {
      console.error(error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchTweets(0);
  }, [fetchTweets]);

  useEffect(() => {
    const handleScroll = () => {
      if ((window.innerHeight + window.scrollY) >= document.body.scrollHeight - 200 && !isLoading) {
        const newOffset = offset + 100;
        setOffset(newOffset);
        fetchTweets(newOffset);
      }
    };

    window.addEventListener('scroll', handleScroll);

    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }, [offset, fetchTweets, isLoading]);

  return (
    <div className="grid grid-cols-1 gap-1 sm:grid-cols-8 lg:grid-cols-8">
      {tweets
        .filter(tweet => tweet.content.includes(query) && tweet.media && tweet.media.length > 0)
        .map((tweet, index) => (
          <TweetCard key={`${tweet.original_tweet_id}_${index}`} tweet={tweet} />
        ))}
    </div>
  );
};

export default TweetList;
