ra93Config = ra93Config or {}
ra93Config.Gangs = {} -- All of below has been migrated into qb-jobs
if not ra93Config.QBJobsStatus then
 ra93Config.Gangs = {
  ['none'] = {
   label = 'No Gang',
   grades = {
    ['0'] = {
     name = 'Unaffiliated'
    },
   },
  },
  ['lostmc'] = {
   label = 'The Lost MC',
   grades = {
    ['0'] = {
     name = 'Recruit'
    },
    ['1'] = {
     name = 'Enforcer'
    },
    ['2'] = {
     name = 'Shot Caller'
    },
    ['3'] = {
     name = 'Boss',
     isboss = true
    },
   },
  },
  ['ballas'] = {
   label = 'Ballas',
   grades = {
    ['0'] = {
     name = 'Recruit'
    },
    ['1'] = {
     name = 'Enforcer'
    },
    ['2'] = {
     name = 'Shot Caller'
    },
    ['3'] = {
     name = 'Boss',
     isboss = true
    },
   },
  },
  ['vagos'] = {
   label = 'Vagos',
   grades = {
    ['0'] = {
     name = 'Recruit'
    },
    ['1'] = {
     name = 'Enforcer'
    },
    ['2'] = {
     name = 'Shot Caller'
    },
    ['3'] = {
     name = 'Boss',
     isboss = true
    },
   },
  },
  ['cartel'] = {
   label = 'Cartel',
   grades = {
    ['0'] = {
     name = 'Recruit'
    },
    ['1'] = {
     name = 'Enforcer'
    },
    ['2'] = {
     name = 'Shot Caller'
    },
    ['3'] = {
     name = 'Boss',
     isboss = true
    },
   },
  },
  ['families'] = {
   label = 'Families',
   grades = {
    ['0'] = {
     name = 'Recruit'
    },
    ['1'] = {
     name = 'Enforcer'
    },
    ['2'] = {
     name = 'Shot Caller'
    },
    ['3'] = {
     name = 'Boss',
     isboss = true
    },
   },
  },
  ['triads'] = {
   label = 'Triads',
   grades = {
    ['0'] = {
     name = 'Recruit'
    },
    ['1'] = {
     name = 'Enforcer'
    },
    ['2'] = {
     name = 'Shot Caller'
    },
    ['3'] = {
     name = 'Boss',
     isboss = true
    },
   },
  }
 }
end