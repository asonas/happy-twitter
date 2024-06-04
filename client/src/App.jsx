import React, { useState } from 'react';
import TweetList from './components/TweetList';

const App = () => {
  const [query, setQuery] = useState('');

  return (
    <div className="container mx-auto p-4">
      <div className="mb-4">
        <h1 className="text-2xl font-bold">Search Tweets</h1>
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search tweets..."
          className="p-2 border border-gray-300 rounded"
        />
      </div>
      <TweetList query={query} />
    </div>
  );
};

export default App;
