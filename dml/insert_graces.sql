SELECT graces_collect(
    p_link => 'https://www.dolthub.com/blog/2024-10-15-dolt-use-cases/', 
    p_description => NULL,
    p_tags => NULL,
    p_player => 'manhthd'
);

SELECT graces_collect(
    p_link => 'https://jack-vanlightly.com/blog/2023/4/24/why-apache-kafka-doesnt-need-fsync-to-be-safe', 
    p_description => NULL,
    p_tags => ARRAY['#kafka'],
    p_player => 'manhthd'
);

SELECT graces_collect(
    p_link => 'https://www.confluent.io/blog/apache-kafka-purgatory-hierarchical-timing-wheels/', 
    p_description => NULL,
    p_tags => ARRAY['#kafka'],
    p_player => 'manhthd'
);

SELECT graces_collect(
    p_link => 'https://www.confluent.io/blog/hands-free-kafka-replication-a-lesson-in-operational-simplicity/', 
    p_description => 'Kafka removed replica.lag.max.messages for operational simplicity',
    p_tags => ARRAY['#kafka'],
    p_player => 'manhthd'
);

