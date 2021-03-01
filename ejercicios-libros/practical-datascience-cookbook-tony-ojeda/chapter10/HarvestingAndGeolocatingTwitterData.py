#Harvesting and Geolocating Twitter Data

from twython import Twython

def twitter_oauth_login():
    
    API_KEY = 'J9C3BTf9RzfKgUc4hjYJeeMft'
    API_SECRET = 'CmjePt2DHnmYZLObLMjCbvm9YDQR0cgFPXZ7xSuCDNY1p3l7ZU'
    ACCESS_TOKEN = '770137282196172801-4uRxztMJ2qWHdLqVBNngTT2STQZbcn0'
    ACCESS_TOKEN_SECRET = 'Y3TGhuwEeeWla4rSnEWGVSk1OcfgyT7ibunSLKLfwqcDu'
    
    twitter = Twython(API_KEY, API_SECRET, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
    
    return(twitter)


def pull_users_profiles(ids):
    
    users = []
    for i in range(0, len(ids), 100):
        batch = ids[i:i + 100]
        users += twitter.lookup_user(user_id=batch)
        print(twitter.get_lastfunction_header('X-Rate-Limit-Remaining'))
    
    return (users)

# fetch the last 20 status updates from your timeline as a
#20-element list of Python dictionaries.

twitter = twitter_oauth_login()

temp = twitter.get_user_timeline()

#access to the response headers received from Twitter
#twitter.get_lastfunction_header('X-Rate-Limit-Remaining')
#twitter.get_lastfunction_header('X-Rate-Limit-Limit')
#twitter.get_lastfunction_header('X-Rate-Limit-Reset')



#Determining your Twitter followers and friends
friends_ids = twitter.get_friends_ids(count=5000)
friends_ids = friends_ids['ids']

followers_ids = twitter.get_followers_ids(count=5000)
followers_ids = followers_ids['ids']

len(friends_ids), len(followers_ids)

friends_set = set(friends_ids)
followers_set = set(followers_ids)

print('Number of Twitter users who either are our friend or follow you (union):')
print(len(friends_set.union(followers_set)))


print('Number of Twitter users who follow you and are your friend (intersection):')
print(len(friends_set & followers_set))

print("Number of Twitter users you follow that don't follow you (set difference):")
print(len(friends_set - followers_set))

print("Number of Twitter users who follow you that you don't follow (set difference):")
print(len(followers_set - friends_set))

#Pulling Twitter user profiles
friends_profiles = pull_users_profiles(friends_ids)
followers_profiles = pull_users_profiles(followers_ids)

#friends_screen_names = [p['screen_name'] for p in friends_profiles if 'screen_name' in p]
friends_screen_names = [p.get('screen_name') for p in friends_profiles]

print(friends_screen_names)

#Making requests without running afoul of Twitter's rate limits
import time
import math

def pull_users_profiles_limit_aware(ids):

    users = []
    start_time = time.time()
    # Must look up users in
    for i in range(0, len(ids), 10):
        batch = ids[i:i + 10]
        users += twitter.lookup_user(user_id=batch)
        calls_left = float(twitter.get_lastfunction_header('X-Rate-Limit-Remaining'))
        time_remaining_in_window = rate_limit_window - (time.time()-start_time)
        sleep_duration = math.ceil(time_remaining_in_window/calls_left)
        print('Sleeping for: ' + str(sleep_duration) + ' seconds; ' +
        str(calls_left) + ' API calls remaining')
        time.sleep(sleep_duration)
    return (users)


#Storing JSON data to the disk





