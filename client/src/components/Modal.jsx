import React, { useEffect, useState } from 'react';

const Modal = ({ tweet, onClose }) => {
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    const handleKeydown = (e) => {
      if (e.key === 'Escape') onClose();
      if (e.key === 'ArrowRight') setCurrentIndex((prevIndex) => (prevIndex + 1) % tweet.media.length);
      if (e.key === 'ArrowLeft') setCurrentIndex((prevIndex) => (prevIndex - 1 + tweet.media.length) % tweet.media.length);
    };

    window.addEventListener('keydown', handleKeydown);
    return () => window.removeEventListener('keydown', handleKeydown);
  }, [onClose, tweet.media.length]);

  const getMediaUrl = (media) => media.cached_url || media.url;

  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center"
      onClick={onClose}
    >
      <div
        className="bg-white p-6 rounded shadow-lg relative"
        onClick={(e) => e.stopPropagation()}
      >
        <button className="absolute top-0 right-0 m-2" onClick={onClose}>
          &times;
        </button>
        {tweet.media[currentIndex].type === 'photo' ? (
          <img src={getMediaUrl(tweet.media[currentIndex])} alt="Tweet media" />
        ) : (
          <video src={getMediaUrl(tweet.media[currentIndex])} controls />
        )}
        <div className="mt-4">{tweet.content}</div>
        <a href={tweet.url} target="_blank" rel="noopener noreferrer">
          View on Twitter
        </a>
      </div>
    </div>
  );
};

export default Modal;
