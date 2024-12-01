#!/usr/bin/env bb

(require '[clojure.string :as str])

(defn- parse []
  (mapv (fn [col] (sort col))
        (apply map vector (map #(map read-string (str/split % #" +")) (line-seq (java.io.BufferedReader. *in*))))))

(defn score [n freq-map]
  (* n (get freq-map n 0)))

(let [[l1 l2] (parse)
      freqs (frequencies l2)]
  (println (reduce + (map (comp abs -) l1 l2)))
  (println (reduce + (map #(score % freqs) l1))))
