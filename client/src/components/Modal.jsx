import React from 'react';

const Modal = ({ tweet, onClose }) => {
  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center"
      onClick={onClose}
    >
      <div
        className="bg-white p-6 rounded shadow-lg"
        onClick={(e) => e.stopPropagation()}
      >
        <button className="absolute top-0 right-0 m-2" onClick={onClose}>
          &times;
        </button>
        {tweet.media.map((media) => (
          <div key={media.id} className="mb-4">
            {media.type === 'photo' ? (
              <img src={media.url} alt="Tweet media" />
            ) : (
              <video src={media.url} controls />
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default Modal;
