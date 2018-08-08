CREATE TABLE `fluent` (
    `id` BLOB PRIMARY KEY,
    `name` TEXT NOT NULL,
    `batch` INTEGER NOT NULL,
    `createdAt` REAL,
    `updatedAt` REAL
);


CREATE TABLE `users` (
    `id` BLOB PRIMARY KEY,
    `name` TEXT NOT NULL,
    `username` TEXT NOT NULL,
    `password` TEXT NOT NULL
);
CREATE UNIQUE INDEX `_fluent_index_users_username` 
    ON `users` (`username`);

CREATE TABLE `acronyms` (
    `id` INTEGER PRIMARY KEY,
    `short` TEXT NOT NULL,
    `long` TEXT NOT NULL,
    `userID` BLOB NOT NULL,
    FOREIGN KEY (`userID`) REFERENCES `users` (`id`)
);

CREATE TABLE `categories` (
    `id` INTEGER PRIMARY KEY,
    `name` TEXT NOT NULL
);


CREATE TABLE `acronym_category` (
    `id` INTEGER PRIMARY KEY,
    `acronymID` INTEGER NOT NULL,
    `categoryID` INTEGER NOT NULL,
    FOREIGN KEY (`acronymID`) REFERENCES `acronyms` (`id`),
    FOREIGN KEY (`categoryID`) REFERENCES `categories` (`id`)
);


CREATE TABLE `tokens` (
    `id` BLOB PRIMARY KEY,
    `token` TEXT NOT NULL,
    `userID` BLOB NOT NULL
);

