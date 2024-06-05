import React, { useState } from 'react';
import Modal from './Modal';

const TweetCard = ({ tweet }) => {
  const [isOpen, setIsOpen] = useState(false);

  const renderMedia = (media) => {
    if (media.type === 'photo') {
      return (
        <img
          src={media.cached_url || media.url}
          alt="Tweet media"
          onClick={() => setIsOpen(true)}
          className="cursor-pointer object-cover w-32 h-32"
        />
      );
    }
    if (media.type === 'video') {
      return (
        <video
          src={media.cached_url || media.url}
          onClick={() => setIsOpen(true)}
          className="cursor-pointer object-cover w-32 h-32"
          controls
        />
      );
    }
    return null;
  };

  return (
    <>
      <div className="bg-white">
        {tweet.media && tweet.media.length > 0 ? renderMedia(tweet.media[0]) : null}
      </div>
      {isOpen && <Modal tweet={tweet} onClose={() => setIsOpen(false)} />}
    </>
  );
};

export default TweetCard;
