import React, { useState } from 'react';
import Modal from './Modal';

const TweetCard = ({ tweet }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <div className="bg-white p-4 rounded shadow">
        {tweet.media && tweet.media.length > 0 && (
          <img
            src={tweet.media[0].url}
            alt="Tweet media"
            onClick={() => setIsOpen(true)}
            className="cursor-pointer"
          />
        )}
        <div className="mt-4">{tweet.content}</div>
      </div>
      {isOpen && <Modal tweet={tweet} onClose={() => setIsOpen(false)} />}
    </>
  );
};

export default TweetCard;
